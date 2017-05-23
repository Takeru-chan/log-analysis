#! /bin/sh
LOG="/var/log/nginx/access.log"
if !(test -e $LOG); then
  echo "There is no log file."
  exit
fi
grep -i -v "turned over\|wp-cron\|bot\|spider\|crawl\|^$" $LOG | awk -F\" '{split($1,sfld," "); split($2,req," "); \
print sfld[2]"\040"sfld[5]"\040"$4"\040"sfld[1]req[2]"\040\042"$6"\042"}'
