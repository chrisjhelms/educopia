#!/bin/bash 
# installs in private/public keys from url in /etc/lockss/keys
# must run as root
# has -help option 

cmd=`basename $0`
cmdline="$0 $@";

host=`hostname`

log_dir=/var/log/lockss/metaarchive/keys
log_file=`date "+%Y-%m-%d:%H:%M:%S"`-`basename $cmd .sh`.log
ks_dir=/etc/lockss/keys
ks_url=https://admin.metaarchive.org/cacheadmin/lockss/keys
private="no";
info="no";
start_daemon="yes";

function usage { 
cat << EOF 
usage: $cmd OPTIONS 

This script installs the public keystore 

OPTIONS: 
   -D      do not start LOCKSS daemon 
   -h	   show this message 
   -i	   print current status info only (do not update keys) 
   -k      local keystore directory containing public and private keys  ($ks_dir)
   -l      log file directory ($log_dir) 
   -n	   host name ($host) 
   -p 	   install private keys 
   -u      url where keystore files are ready for download  ($ks_url) 

EOF
}

# create log dir if does not exist 
mkdir -p $log_dir 
function log  {
        echo  $@
        echo  $@ >> $log_dir/$log_file 
}

function status_summary 
{
   log "::: ----------------------- "
   log "::: Status  Summary " 
   log "::: ----------------------- "
   for file in $ks_dir/$host.jceks $ks_dir/$host.pass $ks_dir/$pub_keystore ; do
       if [ ! -e $file ] ; then 
           log "ERROR no $file"; 
       fi
   done 
   
   if [ "X$keytool" != "X" ] ; then 
         msg=`$keytool -list -storetype jceks -keystore $ks_dir/$host.jceks -storepass $host | fgrep MD5 | head -1`
         log "$host.jceks  $msg" 
         msg=`$keytool -list -storetype jceks -keystore $ks_dir/$pub_keystore -storepass password | fgrep $host  ` 
         log "$pub_keystore $msg" 
   fi 
   log ""
   log "$ks_dir:"
   ls -ld $ks_dir $ks_dir/* 
   ls -ld $ks_dir $ks_dir/* >>   $log_dir/$log_file 
}

function error  {
        log  "ERROR: " $@
	wait_daemon_up 
        rm -rf $tmp
	log ""
	status_summary 
        exit 1
}

if [ $EUID -ne 0 ]; then 
        log  "ERROR: " "must run as root"
	exit 1
fi

if [ ! -e $ks_dir ]; then 
   mkdir $ks_dir 
   log "created $ks_dir" 
fi


log "DATE: `date`"
log "cmd: $cmdline" 
log "logging to $log_dir/$log_file" 
log "keystore url  $ks_url";

for dir in $JAVA_HOME "/etc/alternatives" "/usr"    ;  do
   if [ -z $jar ] && [ -e "$dir/bin/jar" ] ; then 
       jar="$dir/bin/jar" 
   fi
   if [ -z $jar ] && [ -e "$dir/bin/fastjar" ] ; then 
       jar="$dir/bin/fastjar" 
   fi
   if [ -z $keytool ] && [ -e "$dir/bin/keytool" ] ; then 
       keytool="$dir/bin/keytool" 
   fi
   if [ -z $keytool ] && [ -e "$dir/bin/gkeytool" ] ; then 
       keytool="$dir/bin/gkeytool" 
   fi
   if [ -z $jarsigner ] && [ -e "$dir/bin/jarsigner" ] ; then 
       jarsigner="$dir/bin/jarsigner" 
   fi
   if [ -z $jarsigner ] && [ -e "$dir/bin/gjarsigner" ] ; then 
       jarsigner="$dir/bin/gjarsigner" 
   fi
done
log "jar=$jar"; 
log "jarsigner=$jarsigner"; 
log "keytool=$keytool"; 
exit 0 

# set -x
here=`pwd`
pub_keystore=pub-keystore.jceks  # public keystore 
pub_keystore_md5=pkj_sum		    # .... md5sum

#  Local Keystore Directory
mkdir -p $ks_dir
chown root:root $ks_dir 
chmod 755 $ks_dir 
log "keystore dir $ks_dir"
# download keystore files to  /tmp/metaarchive 
tmp=/tmp/metaarchive/$$
mkdir -p $tmp

# use to test whether damon is running 
LOCKSSPID=/var/run/lockss.pid

function wait_daemon_down
{
      log "stopping LOCKSS daemon "
      if [ -e $LOCKSSPID ]; then
         /etc/init.d/lockss stop
         log "Waiting for LOCKSS daemon to go down..." 
         sleep 1; 
         wait_daemon_down
      fi
      log "no LOCKSSPID $LOCKSSPID => daemon down "
}

function wait_daemon_up
{
   if [ $start_daemon == "yes" ]; then 
      if [ ! -e $LOCKSSPID ]; then
         /etc/init.d/lockss start
         log "Waiting for LOCKSS daemon to start..." 
         sleep 1; 
         wait_daemon_up
      fi
      log "found LOCKSSPID $LOCKSSPID => daemon up"
   fi
}

function do_wget_md5 { 
   file=$1
   md5=$2
    
   log "get $file and $md5 to `pwd` "
   log "wget $ks_url/$md5"
   wget --quiet -T 30 -t 2  --no-check-certificate $ks_url/$md5 -O $md5
   if [ ! -s $md5  ]; then
       error "could not get $md5" 
   fi 
   log "wget $ks_url/$file"
   wget --quiet -T 30 -t 2  --no-check-certificate $ks_url/$file -O $file
   if [ ! -s $file  ]; then
       error "could not get $file" 
   fi 

   sum1=$(md5sum $file | awk '{print $1}')
   sum2=`echo -n $(cat $md5)`
   if  [ "$sum2" !=  "$sum1" ]; then
	log "md5sum($file) does not match value from $ks_url/$md5"; 
	error "please try again"
   fi
   log "md5sum($file) matches value from $ks_url/$md5"; 
}

function install_key_file { 
   file=$1
   mode=$2
   ks_dir=$3

   diff $file  $ks_dir/$file 
   if [ $? -eq 0 ]; then  
      log "new $file equal to installed $file" 
   else 
      chown root:root  $file  
      if [ $? -ne 0 ]; then  
	   error "could not change owner of $file to root:root" 
      fi
      chmod $mode $file
      if [ $? -ne 0 ]; then  
	   error "could not change permissions of $file" 
      fi
      cp -p $file  $ks_dir
      if [ $? -ne 0 ]; then  
          error  "could not copy $file to $ks_dir" 
      fi
      log "copied successfully  to $ks_dir/$file"
   fi
   rm $file
}

function do_public { 
   log ">>> ----------------------- "
   log ">>>  Updating public keys "
   log ">>> ----------------------- "
   cd $tmp
   log "saving to $tmp" 
   do_wget_md5 $pub_keystore $pub_keystore_md5 
   wait_daemon_down
   install_key_file $pub_keystore "644"  $ks_dir
   wait_daemon_up
   log "<<< ----------------------- "
   log "<<<  Success: Updating public keys "
   log "<<< ----------------------- "
   cd $here
}


function do_private { 
   log ">>> ----------------------- "
   log ">>>  Getting private keys "
   log ">>> ----------------------- "
   cd $tmp 
   log "saving to $tmp" 
   do_wget_md5 $host.tgz $host.md5sum
   tar xvf $host.tgz 
   if [ $? -ne 0 ]; then  
       error  "could not untar $host.tgz"
   fi
   for file in $host.jceks  $host.pass ; do
      if [ ! -e $file ]; then
	error "$host.tgz did not contain $file" 
      fi
   done
   wait_daemon_down
   log "installing private keys" 
   for file in $host.jceks  $host.pass 
   do 
      install_key_file $file "600"  $ks_dir
   done 
   wait_daemon_up
   cd $here 
   log "<<< ----------------------- "
   log "<<< Success: Getting private keys "  
   log "<<< ----------------------- "
}

set -x
if [ $info != "yes" ] ; then 
   log ""
   do_public 
   
   if [ $private == "yes" ]; then 
      log ""
      do_private 
   fi 
fi

log ""
status_summary 
rm -rf $tmp 
log "SUCCESS $cmd `date`"; 

