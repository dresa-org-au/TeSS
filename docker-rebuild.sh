#!/bin/bash

echo "\nRebuilding image $1 from $2"
docker image rm $1
docker build . -t $1 -f $2

