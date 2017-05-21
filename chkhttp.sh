#! /bin/sh
LOG=/var/log/nginx/access.log
if !(test -e $LOG); then
  echo "There is no file."
  exit
fi
HTTP1=`grep $LOG -e "HTTP/1" | wc -l`
HTTP2=`grep $LOG -e "HTTP/2" | wc -l`
TOTAL=$((HTTP1 + HTTP2))
if test $TOTAL = 0; then
  echo "There is no data."
  exit
fi
RATE=$((HTTP2 * 1000 / TOTAL))
echo "Total access: $TOTAL"
echo "HTTP/2 rate : $RATE" | sed 's/\(.*\)\([0-9]\)/\1\.\2%/g'
