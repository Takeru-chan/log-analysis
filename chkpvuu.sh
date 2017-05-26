#! /bin/sh
LOG="/var/log/nginx/access.log"
<$LOG grep -i -v "turned over\|bot\|spider\|crawl" | cut -d ' ' -f 1,2 | sed 's/^www\.//' | uniq -c | awk '{pv[$2]=pv[$2]+$1; uu[$2]=uu[$2]+1}END{for(key in pv){print key":"pv[key]"("uu[key]")"}}' | sort
