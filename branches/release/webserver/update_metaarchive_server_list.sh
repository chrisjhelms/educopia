#!/bin/bash

# This script checks to see if an updated list of metaarchive servers is available.  This list is formatted as
# an Apache "Allow from XXXX YYYY ZZZZ" line.  It is included in httpd.conf whenever resources need to have
# limited access, but still be available to the metaarchive servers.

# Settings:

if (( $# != 3 ))
then
        echo "Usage: $0 URL target_file email_addresses"
        exit 1
fi

url=$1
target=$2
emails=$3

# Get the remote file

tempfile=/tmp/allow_from_metaarchive.conf 
rm $tempfile 2>/dev/null 
wget --no-check-certificate --quiet --output-document=$tempfile $url

if (( $? != 0 ))
then
	echo "ERROR: Failed to download MetaArchive IP address list from $url" >&2
	echo | mail -s "ERROR: Failed to download MetaArchive IP address list from $url" $emails
	exit 1
fi

# See if it differs from the current file
# If so, move it in place and notify the admins to restart Apache

diff --ignore-space-change --ignore-blank-lines $target $tempfile >/dev/null

if (( $? != 0 ))
then
	hostname=`hostname`
	subject="Apache should be restarted on $hostname because MetaArchive servers have changed"
	diff --ignore-space-change --ignore-blank-lines $target $tempfile | mail -s "$subject" $emails 
	cp -f $tempfile $target 
fi

# Remove the temporary file

rm $tempfile 2>/dev/null
