

#!/bin/bash
LOG_FILE="/var/log/miztiik-$(date +'%Y-%m-%d').json"
LOG_COUNT=50000

for ((i=1; i<=LOG_COUNT; i++)); do


    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    REQ_ID=$(uuidgen)
    STORE_ID=$(shuf -i 10-68 -n 1)
    CUST_ID=$(shuf -i 150-6500 -n 1)
    SKU=$(shuf -i 15000-18000 -n 1)
    QTY=$(shuf -i 1-20 -n 1)
    PRICE=$(echo $((RANDOM % 9001 + 1000)) | sed 's/..$/.&/')
    DISCOUNT=$(echo $((RANDOM % 901 + 100)) | sed 's/.$/.&/')
    GIFT_WRAP=$((RANDOM % 2 == 1))
    PRIORITY_SHIPPING=$((RANDOM % 2 == 1))
    CONTACT_ME="github.com/miztiik"

    JSON_DATA="{\"request_id\": \"$(uuidgen)\", \"event_type\": \"inventory_event\", \"store_id\": $STORE_ID, \"cust_id\": $CUST_ID, \"category\": \"Camera\", \"sku\": $SKU, \"price\": $PRICE, \"qty\": $QTY, \"discount\": $DISCOUNT, \"gift_wrap\": $GIFT_WRAP, \"variant\": \"MystiqueAutomaton\", \"priority_shipping\": $PRIORITY_SHIPPING, \"TimeGenerated\": \"$(date +'%Y-%m-%dT%H:%M:%S')\", \"contact_me\": \"$CONTACT_ME\" }"

    # JSON_DATA="{\"request_id\": \"$(uuidgen)\", \"event_type\": \"inventory_event\", \"store_id\": $STORE_ID, \"cust_id\": $CUST_ID, \"category\": \"Camera\", \"sku\": $SKU, \"price\": $PRICE, \"qty\": $QTY, \"discount\": 8.2, \"gift_wrap\": true, \"variant\": \"red\", \"priority_shipping\": true, \"TimeGenerated\": \"$(date +'%Y-%m-%dT%H:%M:%S')\", \"contact_me\": \"github.com/miztiik\"}"
    echo $JSON_DATA >> $LOG_FILE
    echo "Writing to log: ($i/$LOG_COUNT) $JSON_DATA "
    echo "-------------"
    sleep 0
done


while true; do
    LOG_FILE="/var/log/miztiik-$(date +'%Y-%m-%d').json"
    JSON_DATA="{\"TimeGenerated\": \"$(date +'%Y-%m-%d %H:%M:%S')\", \"message\": \"Miztiik Universe Coordinates: $RANDOM\"}"
    echo $JSON_DATA >> $LOG_FILE
    echo "Writing to log: ($i/$LOG_COUNT) $JSON_DATA "
    # sleep 5
done

MIN=1
MAX=10
LOG_FILE="/var/log/miztiik-$(date +'%Y-%m-%d').json"
while true; do
    # $(( ( RANDOM % 10 )  + 1 ))   
    STORE_ID=$(shuf -i 10-68 -n 1)
    CUST_ID=$(shuf -i 150-6500 -n 1)
    SKU=$(shuf -i 15000-18000 -n 1)
    QTY=$(shuf -i 1-20 -n 1)

    JSON_DATA="{\"request_id\": \"$(uuidgen)\", \"event_type\": \"inventory_event\", \"store_id\": $RESULT, \"cust_id\": $CUST_ID, \"category\": \"Camera\", \"sku\": $SKU, \"price\": 2.52, \"qty\": $QTY, \"discount\": 8.2, \"gift_wrap\": true, \"variant\": \"red\", \"priority_shipping\": true, \"TimeGenerated\": \"$(date +'%Y-%m-%dT%H:%M:%S')\", \"contact_me\": \"github.com/miztiik\"}"
    echo $JSON_DATA >> $LOG_FILE
    echo "Writing to log: ($i/$LOG_COUNT) $JSON_DATA "
    sleep 5
done




#!/bin/bash

#!/bin/bash
sudo su
COMPUTER_NAME=$(hostname)
LOG_COUNT=50000
LOG_DIR="/var/log"
LOG_FILE="$LOG_DIR/miztiik-$(date -u +"%Y-%m-%d").json"

echo "Generating $LOG_COUNT records..."

for (( RECORD_NUMBER=1; RECORD_NUMBER<=LOG_COUNT; RECORD_NUMBER++ ))
do    
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    REQ_ID=$(uuidgen)
    RANDOM_NUMBER=$(( $RANDOM % 100 ))
    RANDOM_CONTENT=$(uuidgen)
    STORE_ID=$(shuf -i 10-68 -n 1)
    CUST_ID=$(shuf -i 150-6500 -n 1)
    SKU=$(shuf -i 15000-18000 -n 1)
    QTY=$(shuf -i 1-20 -n 1)
    PRICE=$(echo $((RANDOM % 9001 + 1000)) | sed 's/..$/.&/')

    # LOG_RECORD="$TIMESTAMP : $COMPUTER_NAME : $RANDOM_NUMBER : Record number $RECORD_NUMBER with random content $RANDOM_CONTENT"
    LOG_RECORD="$TIMESTAMP : $CUST_ID : $PRICE : $STORE_ID :  : $SKU : $QTY :  : Camera : $REQ_ID $COMPUTER_NAME"

    echo -e "$RECORD_NUMBER of $LOG_COUNT \n $LOG_RECORD \n "
    echo "$LOG_RECORD" >> "$LOG_FILE"
    # sleep 1
done



'source|extend Data = substring(source, 22, strlen(source))| extend Dynamic = split(Data," ")| extend store_id = toint(Dynamic[0]), cust_id = toint(Dynamic[1]), sku = toint(Dynamic[2]), qty = toint(Dynamic[3]), price = toreal(Dynamic[4]), category = tostring(Dynamic[5]), req_id = tostring(Dynamic[6])| project-away source, Data, Dynamic'