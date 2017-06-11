#!/bin/bash

to="$1"
subject="$2"
message="$(echo "$3" | tr -d '\r')"
url="${4?usage: $0 to subject message url [username]}"
username="${5:-Zabbix}"

trigger_name="$(echo "$message" | sed -n 's/^Trigger: //p')"
trigger_status="$(echo "$message" | sed -n 's/^Trigger status: //p')"
trigger_severity="$(echo "$message" | sed -n 's/^Trigger severity: //p')"
trigger_url="$(echo "$message" | sed -n 's/^Trigger URL: //p')"
item1="$(echo "$message" | sed -n 's/^1\. //p')"
item2="$(echo "$message" | sed -n 's/^2\. //p')"
item3="$(echo "$message" | sed -n 's/^3\. //p')"
event_id="$(echo "$message" | sed -n 's/^Original event ID: //p')"

case "$trigger_status" in
    OK)
	emoji=':smile:'
	case "$trigger_severity" in
	    Information)
		color="#439FE0"
		;;
	    *)
		color="good"
		;;
	esac
	;;
    PROBLEM)
	emoji=':frowning:'
	case "$trigger_severity" in
	    Information)
		color="#439FE0"
		;;
	    Warning)
		color="warning"
		;;
	    *)
		color="danger"
		;;
	esac
	;;
    *)
	emoji=':ghost:'
	color="#808080"
	;;
esac

item_to_json () {
    local title="$1"
    local item="$2"
    local misc="${3:-}"
    case "$item" in
	*UNKNOWN*|'')
	    ;;
	*)
	    echo "{\"title\":\"${title//\"/\\\"}\",\"value\":\"${item//\"/\\\"}\"$misc},"
	    ;;
    esac
}

fields="\
$(item_to_json 'Trigger' "${trigger_name}")\
$(item_to_json 'Trigger severity' "${trigger_severity}" ',"short":true')\
$(item_to_json 'Trigger status' "${trigger_status}" ',"short":true')\
$(item_to_json 'Original event ID' "${event_id}" ',"short":true')\
$(item_to_json 'Trigger URL' "${trigger_url}")\
$(item_to_json '1.' "$item1")\
$(item_to_json '2.' "$item2")\
$(item_to_json '3.' "$item3")\
"

payload="payload={
  \"channel\": \"${to//\"/\\\"}\",
  \"username\": \"${username//\"/\\\"}\",
  \"icon_emoji\": \"${emoji}\",
  \"attachments\": [
    {
      \"fallback\": \"${subject//\"/\\\"}\",
      \"title\": \"${subject//\"/\\\"}\",
      \"title_link\": \"${trigger_url//\"/\\\"}\",
      \"color\": \"${color}\",
      \"fields\": [${fields%,}]
    }
  ]
}"
curl -m 5 --data-urlencode "${payload}" "$url"
