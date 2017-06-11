#!/bin/bash
set -euo pipefail
: ${ZABBIX_SERVER:=127.0.0.1}
: ${NASNE_HOSTNAME:=${1%_*}}
: ${NASNE_IP:=${1#*_}}
: ${REC_INFO_FILE:=/run/nasne/rec.$NASNE_IP.txt}
: ${NOTICE_SOCK:=}

sender () {
    zabbix_sender -z "$ZABBIX_SERVER" -s "$NASNE_HOSTNAME" -i -
}

JSON=$(curl -s "http://$NASNE_IP:64210/status/HDDInfoGet?id=0")
usedVolumeSize=$(echo "$JSON" | jq -r '.HDD.usedVolumeSize')
freeVolumeSize=$(echo "$JSON" | jq -r '.HDD.freeVolumeSize')
{
    echo "- nasne.hdd.free $usedVolumeSize"
    echo "- nasne.hdd.used $freeVolumeSize"
} | sender

JSON=$(curl -s "http://$NASNE_IP:64210/status/dtcpipClientListGet")
play=$(echo "$JSON" | jq -r '.number')
if [ "$(echo "$JSON" | jq -r '.client')" = "null" ]; then
    live=0
else
    live=$(echo "$JSON" | jq -r '.client | map(select(.liveInfo)) | length')
fi
{
    echo "- nasne.status.play $play"
    echo "- nasne.status.live $live"
} | sender

# 番組終了直後も録画状態が続いているので、その時の情報取得を避けるために少し sleep
# していたが、開始時刻をずらしたのでコメントアウト
#sleep 10

JSON=$(curl -s "http://$NASNE_IP:64210/status/boxStatusListGet")
if [ "$(echo "$JSON" | jq -r '.tvTimerInfoStatus.nowId')" = "" ]; then
    rec=0
else
    rec=1
fi
networkId=$(echo "$JSON" | jq -r '.tuningStatus.networkId')
transportStreamId=$(echo "$JSON" | jq -r '.tuningStatus.transportStreamId')
serviceId=$(echo "$JSON" | jq -r '.tuningStatus.serviceId')
old_rec_info=
new_rec_info=
if [ "$rec" -eq 1 ]; then
    JSON=$(curl -s "http://$NASNE_IP:64210/status/channelInfoGet2?networkId=$networkId&transportStreamId=$transportStreamId&serviceId=$serviceId&withDescriptionLong=0")
    startDateTime=$(echo "$JSON" | jq -r '.channel.startDateTime')
    title=$(echo "$JSON" | jq -r '.channel.title')
    channel=$(echo "$JSON" | jq -r '.channel.service.serviceName')
    description=$(echo "$JSON" | jq -r '.channel.description' | tr $'\n' ' ')
    new_rec_info="$startDateTime $title ($channel) $description"
    if [ -f "$REC_INFO_FILE" ]; then
        old_rec_info=$(cat "$REC_INFO_FILE")
    fi
    echo "$new_rec_info" > "$REC_INFO_FILE"
fi
if [ "$old_rec_info" != "$new_rec_info" -a -n "$new_rec_info" ]; then
    rec_start=1
else
    rec_start=0
fi
if [ "$rec_start" -eq 1 -a -n "$NOTICE_SOCK" ]; then
    /etc/zabbix/alert.d/notice.rb "$NOTICE_SOCK" "$NASNE_HOSTNAME $new_rec_info"
fi
{
    echo "- nasne.status.rec $rec"
    if [ "$rec_start" -eq 1 ]; then
        echo "- nasne.info.rec $new_rec_info"
    fi
} | sender
