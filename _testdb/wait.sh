#!/bin/bash
HOST=$1
PORT=$2
echo "Waiting for $HOST:$PORT..."


# timeout 30 bash -c "until nc -z $HOST $PORT; do sleep 1; done"


while ! nc -z -v -w5 $HOST $PORT; do   
  sleep 1
  echo "Trying $HOST:$PORT again..."
done