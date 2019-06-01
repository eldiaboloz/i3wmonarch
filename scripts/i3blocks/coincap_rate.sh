#!/usr/bin/env bash
set -e
coin="${BLOCK_INSTANCE:-"bitcoin"}"
data="$(curl -L "https://api.coinmarketcap.com/v1/ticker/${coin}" 2>/dev/null | jq -j '.[] | "\(.symbol);\(.price_usd);\(.percent_change_1h);\(.price_btc)"')"
MY_S="$(echo "$data" | cut -d ';' -f1 | sed -e 's/^"//' -e 's/"$//')"
MY_P="$(echo "$data" | cut -d ';' -f2 | sed -e 's/^"//' -e 's/"$//')"
MY_C="$(echo "$data" | cut -d ';' -f3 | sed -e 's/^"//' -e 's/"$//')"
MY_B="$(echo "$data" | cut -d ';' -f4 | sed -e 's/^"//' -e 's/"$//')"

echo -n "${MY_S}: "
sep=""
if [ ! -z "$1" ]; then
    echo -n "\$"
    echo -n "${MY_P}" | awk '{printf "%6.4f", $1}'
    sep=" | "
fi
if [ "$coin" != "bitcoin" ] && [ ! -z "$2" ]; then
    MY_B=$( bc<<<"$MY_B*100000000" | cut -d '.' -f1)
    echo -n "${sep}$MY_B SAT"
fi
echo ""
case $BLOCK_BUTTON in
    1) 
        chromium "https://coinmarketcap.com/currencies/${coin}/" > /dev/null 2>&1 &
    ;;
	3)
        chromium "https://coinmarketcap.com/currencies/${coin}/" > /dev/null 2>&1 &
    ;;
esac

if (( $(bc <<< "$MY_C > 0.0") )); then
    color="#00FF00"
else
    color="#FF0000"
fi

echo "${MY_S}"
echo "$color"
exit 0
