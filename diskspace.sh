#!/bin/bash

# HARD DRIVE SPACE
# "P" letter for better output

HDS=`df -Ph | awk '{print $5+0}'`

# LOOK FOR DRIVES OVER 95

for drives in $HDS
do
        if [ $drives -ge 95 ]; then
                for l in $drives
                do
                df -h | grep $l%
                done >> /usr/local/bin/out.dat



        fi
done


# Adding /dev/null 2>&1 for NOT generating error output

sed -i -e 1i$HOSTNAME' is low on disk space' /usr/local/bin/out.dat > /dev/null 2>&1



if [ -s /usr/local/bin/out.dat ]; then
cat /usr/local/bin/out.dat | mail -s "HARD DISK SPACE ALERT!!!" bjonoski@betware.com,bdobric@betware.com
fi

rm -f /usr/local/bin/out.dat 2>&1

