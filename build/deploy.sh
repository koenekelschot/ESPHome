#!/bin/bash

rsync -athv .ESPHOME_VERSION $SSH_USER@$SSH_HOST:$SSH_FOLDER_DOCKER/.ESPHOME_VERSION

echo "Cleaning folder"
ssh $SSH_USER@$SSH_HOST "find $SSH_FOLDER_DOCKER/volumes/esphome -type f -name *.yaml -not -name secrets.yaml -exec rm {} \;"

echo "Copying files"
for i in `find . -maxdepth 1 -type f -name "*.yaml" -not -name "fake_secrets.yaml" 2>/dev/null`
do
    echo "Copying file $i"
    rsync -athv $i $SSH_USER@$SSH_HOST:$SSH_FOLDER_DOCKER/volumes/esphome/$i
done