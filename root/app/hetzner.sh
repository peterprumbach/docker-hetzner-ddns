#!/usr/bin/with-contenv sh

hetzner() {
  if [ -f "$API_KEY_FILE" ]; then
      API_KEY=$(cat $API_KEY_FILE)
  fi

  curl -sSL \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Auth-API-Token: $API_KEY" \
  "$@"
}

getLocalIpAddress() {
  if [ "$RRTYPE" == "A" ]; then
    IP_ADDRESS=$(ip addr show $INTERFACE | awk '$1 == "inet" {gsub(/\/.*$/, "", $2); print $2; exit}')
  elif [ "$RRTYPE" == "AAAA" ]; then
    IP_ADDRESS=$(ip addr show $INTERFACE | awk '$1 == "inet6" {gsub(/\/.*$/, "", $2); print $2; exit}')
  fi

  echo $IP_ADDRESS
}

getCustomIpAddress() {
  IP_ADDRESS=$(sh -c "$CUSTOM_LOOKUP_CMD")
  echo $IP_ADDRESS
}

getPublicIpAddress() {
  if [ "$RRTYPE" == "A" ]; then
    # Use DNS_SERVER ENV variable or default to 1.1.1.1
    DNS_SERVER=${DNS_SERVER:=1.1.1.1}

    # try dns method first.
    CLOUD_FLARE_IP=$(dig +short @$DNS_SERVER ch txt whoami.cloudflare +time=3 | tr -d '"')
    CLOUD_FLARE_IP_LEN=${#CLOUD_FLARE_IP}

    # if using cloud flare fails, try opendns (some ISPs block 1.1.1.1)
    IP_ADDRESS=$([ $CLOUD_FLARE_IP_LEN -gt 15 ] && echo $(dig +short myip.opendns.com @resolver1.opendns.com +time=3) || echo "$CLOUD_FLARE_IP")

    # if dns method fails, use http method
    if [ "$IP_ADDRESS" = "" ]; then
      IP_ADDRESS=$(curl -sf4 https://ipinfo.io | jq -r '.ip')
    fi

    echo $IP_ADDRESS
  elif [ "$RRTYPE" == "AAAA" ]; then
    # try dns method first.
    IP_ADDRESS=$(dig +short @2606:4700:4700::1111 -6 ch txt whoami.cloudflare | tr -d '"')

    # if dns method fails, use http method
    if [ "$IP_ADDRESS" = "" ]; then
      IP_ADDRESS=$(curl -sf6 https://ifconfig.co)
    fi

    echo $IP_ADDRESS
  fi
}

verifyToken() {
  hetzner -o /dev/null -w "%{http_code}" "$API"/records
}

getDnsRecordName() {
  echo $SUBDOMAIN
}

getZoneId() {
  hetzner "$API/zones?name=$ZONE" | jq -r '.zones[0].id'
}

getDnsRecordId() {
  hetzner "$API/records?zone_id=$1" | jq -r ".records[] | select(.name == \"$2\") | select (.type == \"$RRTYPE\") | .id"
}

createDnsRecord() {
  hetzner -X POST -d "{\"type\": \"$RRTYPE\",\"name\":\"$2\",\"value\":\"$3\",\"zone_id\":\"$1\" }" "$API/records" | jq -r '.record.id'
}

updateDnsRecord() {
  hetzner -X PUT -d "{\"type\": \"$RRTYPE\",\"name\":\"$3\",\"value\":\"$4\",\"zone_id\":\"$1\" }" "$API/records/$2" | jq -r '.record.id'
}

deleteDnsRecord() {
  hetzner -X DELETE "$API/records/$1"
}

getDnsRecordIp() {
  hetzner "$API/records/$1" | jq -r '.record.value'
}