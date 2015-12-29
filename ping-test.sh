#!/bin/bash


DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
ERR="$DIR/error.log"
target_host="$DIR/host-target-list"
ping_test="ping -c 1"
status_log="$DIR/status.log"

## Check if error file exists
#if [ ! -f $ERR ]; then
#    /usr/bin/touch "$DIR/error.log";
#fi
#
## Check if target host file exists, and whether it has any hosts defined
#if [ ! -f $target_host ]; then
#        /bin/echo "Host target file not found!" >$ERR
#        exit 1
#fi
#
#if [[ -s $target_host ]]; then
#    hosts_to_check=true
#else
#    hosts_to_check=false
#    /bin/echo "Host target file has not hosts to check!" >$ERR
#    exit 1
#fi

#
#if [[ hosts_to_check ]]; then
#    while read ip_address; do
#        $ping_test $ip_address
#        if [[$? = 0]]; then
#            /bin/date >> $status_log
#            echo "Host $ip_address online and available!" >> $status_log
#        elif [[$? = 1]]; then
#            /bin/echo "Host $ip_address is not currently available!" >> $status_log
#            # spawn a recheck process separate from this script?
#        else
#            /bin/date >> $status_log
#            /bin/echo "Host $ip_address check has resulted in an unexpected error" >> $status_log
#        fi
#    done < $target_host
#else
#    exit 1
#fi

while read IP; do 
    $ping_test $IP
    result=$?
    if [[ $result -eq 0 ]];then
        /bin/echo "Success!"
    else
        /bin/echo "Failure!"
    fi
    /bin/echo ""
done < $target_host
