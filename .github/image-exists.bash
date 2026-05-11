#!/usr/bin/env bash

IMAGE=$1
FILE_SHA=$2

if docker manifest inspect $IMAGE:$FILE_SHA
then
    exit 0
else
    exit 1
fi
