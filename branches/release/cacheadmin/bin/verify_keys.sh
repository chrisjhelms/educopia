#!/bin/bash
# run with -help

function unhandled_error {
      echo ERROR: Please contact MetaArchice support with output from this command
      exit 1
}

trap unhandled_error ERR

cmd=`basename $0`
cmdline="$0 $@";

host=`hostname`

#  keystore locations
ks_dir=/etc/lockss/keys				# host keys 
pub_dir=$ks_dir 				# public keys 
www_dir=https://admin.metaarchive.org/cacheadmin/lockss/keys # public key url

# keystore file names 
public_jceks=pub-keystore.jceks  # public keystore 

# keep logs in LOCKSS daemon log dir  
log_dir=/var/log/lockss/metaarchive/keys
log_file=`basename $cmd .sh`.log

function usage()
{
cat << EOF
usage: $cmd options

  Verifies contents of local private keystore agains locally stored
  public keystore and aginst keystore from given web url;

Run as root

OPTIONS:
   -h      Show this message
   -n      hostname  ($host) 
   -k      local keystore directory containg host's keys ($ks_dir) 
   -l      log file directory ($log_dir) 
   -p      local directory containing public keystore file  ($pub_dir) 
   -u	   url of containing $public_jceks ($www_dir) 
EOF
}

function log  {
        echo  $@
}
function error  {
        log  "ERROR: " $@
	exit 1
}

while getopts “hk:l:n:p:u:” OPTION
do
     case $OPTION in
         h)
             usage
             exit 0
             ;;
         k)
             ks_dir=$OPTARG
             ;;
         l)
             log_dir=$OPTARG
             ;;
         n)
             host=$OPTARG
             ;;
         p)
             pub_dir=$OPTARG
             ;;
         u)
             www_dir=$OPTARG
             ;;
         ?)
             usage
             exit 1
             ;;
     esac
done

if [[ -z $host ]] || [[ -z $pub_dir ]] || [[ -z $www_dir ]] 
then
     usage
     exit 1
fi
if [ ! -e $pub_dir ]; then 
	error "no $pub_dir"; 
fi 
if [ ! -e $ks_dir ]; then 
	error "no $ks_dir"; 
fi 

if [ $EUID -ne 0 ]; then 
        log  "ERROR: " "must run as root"
	exit 1
fi


pub_jceks=$pub_dir/$public_jceks
www_jceks=$www_dir/$public_jceks

private_jceks=$ks_dir/$host.jceks
private_pass=$ks_dir/$host.pass

touch $log_dir/$log_file
exec> >(/usr/bin/tee $log_dir/$log_file) 2>&1
log "DATE: `date`"
log "cmd: $cmdline" 
log "logging to $log_dir/$log_file" 

# find jar, keytool, jarsigner commands 
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

# test for existance of keystore files 
if [ ! -e $private_jceks ]; then 
   error "no $private_jceks file" 
fi 
if [ ! -e $private_pass ]; then 
   error "no $private_pass file" 
fi 
if [ ! -e $pub_jceks ]; then 
   error "no $pub_jceks file" 
fi 

if [[ -z $jar ]] || [[ -z $jarsigner ]] || [[ -z $keytool ]] ; then 
   error "must jave jar jarsigner and keytool commands" 
fi

#set -x 
#create jar 
(cd $log_dir; touch FILE; $jar cf somejar.jar FILE;) 

log "sign with keys from $ks_dir" 
set -x 
$jarsigner -keystore $private_jceks -storetype jceks -storepass $host -keypass `cat $private_pass` -signedjar signed.jar $log_dir/somejar.jar  $host.key

log "verify against private keystore: $private_jceks"  
$jarsigner -verify -verbose -certs -storetype jceks -keystore $private_jceks signed.jar  | fgrep FILE  | sed 's/^/private: /'

log "verify against public keystore $pub_jceks"  
$jarsigner -verify -verbose -certs -storetype jceks -keystore $pub_jceks signed.jar  | fgrep FILE  | sed 's/^/public:  /'

log "verify against public keystore $www_jceks"  
log "wget $www_jceks " 
wget --quiet -T 30 -t 2  --no-check-certificate $www_jceks -O $log_dir/www_jceks
if [ ! -s $log_dir/www_jceks  ]; then
   log "could not get $www_jceks" 
else 
$jarsigner -verify -verbose -certs -storetype jceks -keystore $log_dir/www_jceks signed.jar  | fgrep FILE  | sed 's/^/url:     /'
fi 

rm  $log_dir/somejar.jar $log_dir/FILE $log_dir/www_jceks
exit 0

