#!/usr/bin/env bash
allcoins=$(curl -L https://api.coinmarketcap.com/v1/ticker/ 2>/dev/null | jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv')
#allcoins=$(cat /tmp/coins.json | jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv')
fieldsymbol="symbol"
fieldprice="price_usd"
symbolpos=""
pricepos=""
fieldcounter=1
while read -r field; do
    if [ "$field" = '"'$fieldprice'"' ]; then
        pricepos="$fieldcounter"
    fi
    if [ "$field" = '"'$fieldsymbol'"' ]; then
        symbolpos="$fieldcounter"
    fi
    fieldcounter=$((fieldcounter+1))
done < <(echo "$allcoins" | sed -n 1p | tr "," "\n")

coins=${@:-"bitcoin"}

printme=""
while read -r coin; do
    coinline=$(echo "$allcoins" | grep -- '"'$coin'"')
    symbol=$(echo "$coinline" | cut -d ',' -f${symbolpos} | sed -e 's/^"//' -e 's/"$//')
    price=$(echo "$coinline" | cut -d ',' -f${pricepos} | sed -e 's/^"//' -e 's/"$//')
    printme="${printme}${symbol}: \$$price | "
done < <(echo "$coins" | tr ' ' '\n')

printme="${printme::-2}"
echo "$printme"

color="#FFFFFF"
echo "$color"
echo "$color"
exit 0
