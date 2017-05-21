#! /bin/sh
LOG=/var/log/nginx/access.log
if !(test -e $LOG); then
  echo "There is no file."
  exit
fi
HTTP1=0
HTTP2=0
while read LINE
do
  case $LINE in
    *HTTP/1*)
      HTTP1=$((HTTP1 + 1));;
    *HTTP/2*)
      HTTP2=$((HTTP2 + 1));;
  esac
done<$LOG
TOTAL=$((HTTP1 + HTTP2))
if test $TOTAL = 0; then
  echo "There is no data."
  exit
fi
RATE=$((HTTP2 * 1000 / TOTAL))
echo "Total access: $TOTAL"
echo "HTTP/2 rate : $RATE" | sed 's/\(.*\)\([0-9]\)/\1\.\2%/g'
