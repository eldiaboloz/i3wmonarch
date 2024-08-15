#!/usr/bin/env bash

token="${GOTIFY_CLIENT_TOKEN}"
if [ "${GOTIFY_SERVER_SSL:-1}" -gt 0 ]; then
  proto=wss
else
  proto=ws
fi
uri="${proto}://${GOTIFY_SERVER_URL}/stream"
while read line
do
  prio="$(echo "$line" | jq -r '.priority')"
  [[ "${prio}" -lt "${GOTIFY_MIN_PRIO:-7}" ]] && continue
  # img src: https://github.com/gotify/logo/blob/master/gotify-logo-small.png
  DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
    notify-send \
    --icon=/home/iliyan/dev/i3wmonarch/files/gotify.png \
    --category=network \
    "$(echo "$line" | jq -r '.title')" \
    "$(echo "$line" | jq -r '.message')" \
    -t 5000
done < <(websocat -H "X-Gotify-Key: ${token}" -t - autoreconnect:"${uri}")
