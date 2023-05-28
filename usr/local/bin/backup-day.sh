#!/bin/bash

sudo /usr/bin/tar -czvf /mnt/s3disk/day/backup.tar.gz --exclude=/bin --exclude=/boot --exclude=/dev --exclude=/mnt --exclude=/proc --exclude=/sys --exclude=/tmp --exclude=/media --exclude=/lost+found -c /