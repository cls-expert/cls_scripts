#!/bin/bash


SCRIPTDIR=$(dirname $0)
.	$SCRIPTDIR/functions.sh

yum install curl -y &> /dev/null
USERNAME=mzaric
PASSWORD=
COMMENT=$(shuf -n1 $SCRIPTDIR/random_descriptions.txt)
DATE=`date +%Y-%m-%d`
# Override current date in format: y-m-d
#DATE=2017-08-15


# You can not log Sunday/Saturday on Sunday/Saturday even if overriden
if [ $DATE == `date +%Y-%m-%d` ];then
DAYOFTHEWEEK
else
echo "Current date is overriden to $DATE"
sleep 5
fi



sum_logged_hours
if [ -z $SUM ]; then #sum is not empty string!
echo -e "\n\n\nLog 8 hours\n\n\n"
sleep 5
HOURSTOLOG=28800
worklog
else
echo -e "\n\n\nLog $(( 28800 - $SUM )) seconds\n\n\n"
sleep 5
HOURSTOLOG=$(( 28800 - $SUM ))
worklog
fi

