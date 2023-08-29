#!/bin/bash

SERVICE=$1
TEXT=$2


while ! docker compose -f _testdb/docker-compose.yml logs -n 5 $SERVICE | grep "$TEXT"; do
    sleep 2
    echo "Check for '$TEXT' in $SERVICE again"
done
