#!/bin/bash

###################################
## Simple Website Uptime Monitor ##
###################################
#                                 #
#      Written by Will Nave       #
#        December 2015            #
#                                 #
#      Written for use on         #
#        Debian/Ubuntu            #
#                                 #
###################################
 
# ------------------------------------------------------------------------------------- #
#                                                                                       #
# This program is free software: you can redistribute it and/or modify it under the     #
# terms of the GNU General Public License as published by the Free Software             #
# Foundation, either version 3 of the License, or (at your option) any later version.   #
#                                                                                       #
# This program is distributed in the hope that it will be useful, but WITHOUT ANY       #
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A       #
# PARTICULAR PURPOSE. See the GNU General Public License for more details.              #
#                                                                                       #
# You should have received a copy of the GNU General Public License along with this     #
# program. If not, see http://www.gnu.org/licenses/.                                    #
#                                                                                       #
# *See inlcuded COPYING file                                                            #
# ------------------------------------------------------------------------------------- #


# The following script will monitor a user generated list of sites and
# update status to a simple web page; as well as generate an availability
# log for tracking length of any downtime.
#
# This script is meant to be implemented via a Cron task using whatever interval 
# of time deemed necessary. The script uses the fping package to evaluate a 
# site's availability and reports results to a simple webpage and availability log.
#
# Upon launch the script checks to see if the fping package is installed, verifies
# that all of the necessary files exist, and verifies the site_list is not empty.  



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

