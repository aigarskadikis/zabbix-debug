#!/bin/bash


curl -s --location --request POST 'https://zbx.catonrug.net/api_jsonrpc.php' \
--header 'Content-Type: application/json' \
-d '
{
    "jsonrpc": "2.0",
    "method": "alert.get",
    "params": {
        "output": "extend"
    },
    "auth": "5f41626816fa83ed0201290c19a57261",
    "id": 1
}
' | jq .


# show already sent messages
curl --location --request POST 'https://zbx.catonrug.net/api_jsonrpc.php' \
--header 'Content-Type: application/json' \
-d '{
    "jsonrpc": "2.0",
    "method": "alert.get",
    "params": {
        "output": "extend"
    },
    "auth": "5f41626816fa83ed0201290c19a57261",
    "id": 1
}
' | jq '.result[] | select (.status == "1") | .message '

# show failed (status=2) remote commands (alerttype=1)
# https://www.zabbix.com/documentation/current/manual/api/reference/alert/object
curl -s --location --request POST 'https://zbx.catonrug.net/api_jsonrpc.php' \
--header 'Content-Type: application/json' \
-d '
{
    "jsonrpc": "2.0",
    "method": "alert.get",
    "params": {
        "output": "extend"
    },
    "auth": "5f41626816fa83ed0201290c19a57261",
    "id": 1
}
' | jq '.result[] | select (.alerttype == "1") | select (.status == "2") | .message'


