#!/usr/bin/env bash

set -eou pipefail

if [[ -f /var/lib/ddix-monitoring-ptr-query-count.txt ]]; then
        old_ptr_query_count="$(cat /var/lib/ddix-monitoring-ptr-query-count.txt)"
else
        old_ptr_query_count="0"
fi

echo "old_ptr_query_count = ${old_ptr_query_count}" 

new_ptr_query_count="$(knotc stats mod-stats.query-type | grep PTR | cut -d ' ' -f 3)"
echo "new_ptr_query_count = ${new_ptr_query_count}"

token=$(cat "$CREDENTIALS_DIRECTORY/uptime_kuma_push_token")

# lower or grater (counter resets to zero on reboot)
if [[ "$old_ptr_query_count" -ne "$new_ptr_query_count" ]]; then
        echo as112 healthy
        curl -s -o /dev/null "https://status.dd-ix.net/api/push/$token?status=up&msg=OK"
        echo "$new_ptr_query_count" > /var/lib/ddix-monitoring-ptr-query-count.txt
else
        echo as112 broken
        curl -s -o /dev/null "https://status.dd-ix.net/api/push/$token?status=down&msg=DOWN"
fi
