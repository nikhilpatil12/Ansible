#!/bin/bash

ADDRESS="http://debian"
PORT=8080
STACK_NAME="pirate"
PORTAINER_API_URL="https://portainer.nikpatil.com/api"
PORTAINER_API_KEY="ptr_1AE9TKMLYpcN+MIvrbhiFUHBquoTy9euJnBa8n414rE="
ENDPOINT_ID="2"

get_stack_id() {
    curl -s -H "X-API-Key:$PORTAINER_API_KEY" "$PORTAINER_API_URL/stacks" | jq -r ".[] | select(.Name==\"$STACK_NAME\").Id"
}

stop_stack() {
    local stack_id=$1
    curl -s -X POST -H "X-API-Key:$PORTAINER_API_KEY" "$PORTAINER_API_URL/stacks/$stack_id/stop?endpointId=$ENDPOINT_ID"
}
start_stack() {
    local stack_id=$1
    curl -s -X POST -H "X-API-Key:$PORTAINER_API_KEY" "$PORTAINER_API_URL/stacks/$stack_id/start?endpointId=$ENDPOINT_ID"
}

(echo > /dev/tcp/$ADDRESS/$PORT) &>/dev/null
if [ $? -ne 0 ]; then
    echo "Port check failed, restarting stack..."

    STACK_ID=$(get_stack_id)
    echo "Stack ID:$STACK_ID"

    if [ -n "$STACK_ID" ]; then
        stop_stack $STACK_ID
        sleep 10
        start_stack $STACK_ID
        echo "Stack restarted successfully."
    else
        echo "Error: Could not find stack ID for stack name '$STACK_NAME'"
    fi
else
    echo "Port check successful."
fi