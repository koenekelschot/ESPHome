#!/bin/bash

copy_file() {
    echo "Copying file $1"
    sshpass -e scp -o StrictHostKeyChecking=no $1 $SSH_USER:$SSH_FOLDER_ESPHOME/$1
}

export SSHPASS=$SSH_PASS
echo "Cleaning folder"
sshpass -e ssh -o StrictHostKeyChecking=no $SSH_USER "find $SSH_FOLDER_ESPHOME -type f -name *.yaml -not -name secrets.yaml -exec rm {} \;"
echo "Copying files"
for i in `find . -maxdepth 1 -type f -name "*.yaml" -not -name "*.template.yaml" -not -name "fake_secrets.yaml" 2>/dev/null`
do
    copy_file $i
done