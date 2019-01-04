#!/bin/bash

function DAYOFTHEWEEK {
DAY=$(date | awk '{ print $1 }')

case $DAY in


        Sat)   echo "Today is Saturday. Exiting...." && exit 1
                ;;

        Sun)
                echo "Today is Sunday. Exiting...." && exit 1
                ;;

        *)      echo "Logging time for `date`"
                ;;
esac
}


# Calculate number of hours logged for current date
function sum_logged_hours {

# Pull all work logs for current date
HOURS=$(curl -D- -u $USERNAME:$PASSWORD   "https://jira-sandbox.betware.com/rest/tempo-timesheets/3/worklogs/?dateFrom=$DATE&dateTo=$DATE&username=$USERNAME" | grep -o timeSpentSeconds\":[0-9]* | grep -o [0-9]*)

# Convert to array and sum all logged hours for current date
array=( $HOURS )
SUM=0
for i in ${array[@]}
do
  SUM=$(($SUM + $i))
done

# If TOTALL SUM is less then 8 hours, then continue. Else, do nothing.
echo $SUM
sleep 5
if [ $SUM -lt 28800 ]; then
echo "Suming up"
else
echo "Daily hours are 8 hours or more. Exiting..."
exit 1
fi
}

function worklog {

curl -D- -u $USERNAME:$PASSWORD -X POST --data '{"comment":"'"$COMMENT"'","timeSpentSeconds":"'$HOURSTOLOG'","started": "'$DATE'T05:23:39.427+0000"}' -H "Content-Type: application/json" https://jira-sandbox.betware.com/rest/api/2/issue/47826/worklog
}
