#!/bin/bash
# Test script
# antoher test


read -p "Which server would you like to follow?"

case $REPLY in
	bamboo) tail -n20 -f  {/opt/bamboo-data/logs/*,/opt/bamboo/logs/catalina.out,/var/log/httpd/atbamboo01.betware.com_ssl_error_log} | GREP_COLOR='01;32' egrep -i --color=always '.*/opt/bamboo-data/.*|'
	;;
	*) echo "Not present at the moment.Exiting.."
	;;
esac
