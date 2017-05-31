#! /bin/sh
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin
DIR=/usr/local/www/search/
FILE=${DIR}index.html
LOG=/var/log/nginx/access.log.0.gz
TMPLOG=${DIR}temp.log
VALIDLOG=${DIR}valid.log
INVALIDLOG=${DIR}invalid.log
cd $DIR
<$LOG zgrep -v "turned over" > $TMPLOG
<$TMPLOG grep -i -v "bot\|spider\|crawl" > $VALIDLOG
<$TMPLOG grep -i -e "bot\|spider\|crawl" > $INVALIDLOG
echo '<!doctype html><html lang="ja"><head><meta charset="utf-8"><meta name="robots" content="noindex">' > $FILE
echo '<link rel="stylesheet" href="http://yui.yahooapis.com/pure/0.5.0/pure-min.css">' >> $FILE
echo '<link rel="stylesheet" href="./style.css">' >> $FILE
echo "<title>アクセスログ解析結果</title></head><body><h1>アクセスログ解析結果 `date`</h1>" >> $FILE
echo "<h2>サマリー</h2><table class="pure-table">" >> $FILE
echo "<thead><tr><th>ドメイン</th><th>アクセス数</th><th>ユニークユーザー数</th></tr></thead><tbody>" >> $FILE
<$VALIDLOG cut -d ' ' -f 1,2 | sed 's/^www\.//' | uniq -c | \
  awk '{pv[$2]=pv[$2]+$1;uu[$2]=uu[$2]+1;tpv=tpv+$1;tuu[$3]=$3}END{for(key in pv){print "<tr><td>"key"</td><td>"pv[key]"</td><td>"uu[key]"</td></tr>"}; for(key in tuu){n++};print "<tr><td>トータル</td><td>"tpv"</td><td>"n"</td></tr>"}' | \
  sort >> $FILE
echo "</td></tr></tbody></table>" >> $FILE
HTTP1=`grep $VALIDLOG -e "HTTP/1" | wc -l`
HTTP2=`grep $VALIDLOG -e "HTTP/2" | wc -l`
TOTAL=$((HTTP1 + HTTP2))
if test $TOTAL != 0; then
  RATE=$((HTTP2 * 1000 / TOTAL))
  echo $RATE | sed 's/\(.*\)\([0-9]\)/\<p\>HTTP\/2 access rate is \1\.\2%\<\/p\>/' >> $FILE
fi
echo "<p>" >> $FILE
TOTAL=`wc -l $VALIDLOG`
<$VALIDLOG cut -d ':' -f 2 | uniq -c | \
  awk -v total="${TOTAL}" '{print $2"時：";for(i=1;i<=$1*500/total;i++){print "*"};print "<br>"}' >> $FILE
echo "</p>" >> $FILE
echo "<h2>有効アクセスリスト</h2><div class='scr'><ul>" >> $FILE
<$VALIDLOG awk -F\" '{split($1,ARRAY," ");printf("\042%s\042%s\042%s\042\n",ARRAY[2],$4,$6)}' | sort | uniq -c | \
  awk -F\" '{split($1,ARRAY," ");IP[$2]=IP[$2]"<br>"ARRAY[1]" "$3" "$4}END{for (key in IP){printf("<li>%s %s</li>",key,IP[key])}}' >> $FILE
echo "</ul></div><h2>クローラーアクセス状況</h2><div class='scr'><ul>" >> $FILE
<$INVALIDLOG cut -d '"' -f 6 | sort | uniq -c | sort -r | sed 's/\(.*\)/\<li\>\1\<\/li\>/' >> $FILE
echo "</ul></div><h2>POST,HEADリクエスト</h2><div class='scr'><ol>" >> $FILE
<$TMPLOG awk -F\" '($2 !~ /GET/){printf("<li>%s %s<br>%s<br>%s<br>%s</li>",$2,$3,$1,$4,$6)}' >> $FILE
echo "</ol></div><h2>WordPressファイルアクセス</h2><div class='scr'><ul>" >> $FILE
<$TMPLOG awk -F\" '
  ($2 ~ /wp-login/){split($1,ip," ");split($2,file," ");split($3,code," ");array[file[2]]=array[file[2]]"<br>"code[1]" "ip[2]}
  ($2 ~ /xmlrpc/){split($1,ip," ");split($2,file," ");split($3,code," ");array[file[2]]=array[file[2]]"<br>"code[1]" "ip[2]}
  END{for(key in array){printf("<li>%s%s</li>",key,array[key])}}' >> $FILE
echo "</ul></div><h2>非公開ドメインアクセスリスト</h2><div class='scr'><ul>" >> $FILE
<$TMPLOG awk -F\" '
  ($1 ~ /_/){split($1,ip," ");split($2,file," ");split($3,code," ");print ip[2]"\""file[2]"\""code[1]"\""$6}' | \
  awk -F\" '{ip[$1]=ip[1]"<br>"$3" "$2"<br>\""$4"\""}END{for(key in ip){print "<li>"key ip[key]"</li>"}}' >> $FILE
echo "</ul></div><h2>httpステータス</h2><div class='scr'><ul>" >> $FILE
<$TMPLOG awk -F\" '($3 !~ /^ 200 /){split($1,ip," ");split($3,code," ");print code[1]" "ip[2]}' | sort | \
  uniq -c | awk '{data[$2]=data[$2]"<br>"$1" "$3}END{for(key in data){print "<li>"key" "data[key]"</li>"}}' | \
  sort >> $FILE
echo "</ul></div></body></html>" >> $FILE
rm $TMPLOG $VALIDLOG $INVALIDLOG
