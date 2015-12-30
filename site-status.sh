#!/bin/bash






# Variable declarations
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
site_list="$DIR/site_list"
ping_test="fping -c 1"
status_page="$DIR/status.html"
log="$DIR/availability.log"


# Check if all necessary file/package dependecies are met 
if [[ $(dpkg -s fping | grep Status | awk '{print $4}') != "installed" ]]; then
    /bin/echo "Please install fping to use this script..."
    exit 1
fi

if [[ ! -s $site_list ]]; then
    /bin/echo "No sites to monitor!  Please create a line-by-line list of sites in the $site_list file!"
    exit 1
fi

for item in $site_list $status_page $log
do
    if [ ! -f $item ]; then
        /bin/touch $item
    fi
done

# Clear status page before updating
/bin/echo "" > $status_page
/bin/echo "<br />" >> $status_page
/bin/echo "<br />" >> $status_page
/bin/echo "<br />" >> $status_page

# Process site availability checks and update status_page
while read line; do
    $ping_test $line
    result=$?
    if [[ $result -eq 0 ]]; then
        /bin/echo "<h2 style=\"color:green; text-align:center;\"><b>$line</b> is currently available!</h2>" >> $status_page
        /bin/echo $(date) "$line is up!" >> $log
    else
        /bin/echo "<h2 style=\"color:red; text-align:center;\"><b>$line</b> is currently unavailable!</h2>" >> $status_page
        /bin/echo "---> " $(date) "$line is down! ***" >> $log
    fi
done < $site_list

