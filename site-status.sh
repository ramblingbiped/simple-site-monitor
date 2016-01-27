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
ping_test="ping -c 1 -w1"
status_page="$DIR/status.html"
log="$DIR/availability.log"
now=$(date +"%D")


# Check if all necessary file/package dependecies are met 
if [[ ! -s $site_list ]]; then
    /usr/bin/printf "No sites to monitor!  Please create a line-by-line list of sites in the %s file!" $site_list
    exit 1
fi

for item in $site_list $status_page $log
do
    if [ ! -f $item ]; then
        /bin/touch $item
    fi
done

#Clear status page before updating
/usr/bin/printf "" > $status_page
/usr/bin/printf "<br />\n" >> $status_page
/usr/bin/printf "<br />\n" >> $status_page
/usr/bin/printf "<br />\n" >> $status_page

# Process site availability checks and update status_page
while read line; do
    $ping_test $line
    result=$?
    if [[ $result -eq 0 ]]; then
        /usr/bin/printf  "%s %s is up!\n" $now $line >> $log
        curlTest=$(curl -Is -m 2 http://$line | head -n 1)
        if [[ $curlTest == *"TTP/1.1 200 OK"* ]]; then
            /usr/bin/printf "<h2 style=\"color:green; text-align:center;\">Host <b>%s</b> is currently available and the webserver status is:  <b><u>%s</u></b> </h2>\n" $line "200 OK!" >> $status_page
            /usr/bin/printf "     %s webserver response is: %s\n\n" $line "200 OK!" >> $log
        else
            /usr/bin/printf "<h2 style=\"color:green; text-align:center;\">Host <b>%s</b> is currently available, but webserver status is currently not favorable...  <b style=\"color:red;\">Best look into things!</b> </h2>\n" $line >> $status_page
            /usr/bin/printf "---> %s webserver response is not favorable...  Best look into things!\n\n" $line >> $log
        fi
    else
        /usr/bin/printf  "<h2 style=\"color:red; text-align:center;\">Host <b>%s</b> is currently unavailable!</h2>\n" $line >> $status_page
        /usr/bin/printf "---> %s %s is down! ***\n\n" $now $line >> $log
    fi
done < $site_list

