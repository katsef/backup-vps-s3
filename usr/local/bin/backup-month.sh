#!/bin/bash
/usr/bin/find $bk_dir -type f -mtime +365 -exec rm {} \;
date_time=`date +"%Y-%m-%d_%H-%M"`
sudo /usr/bin/tar -czvf /mnt/s3disk/month/backup_$date_time.tar.gz --exclude=/dev --exclude=/mnt --exclude=/proc --exclude=/sys --exclude=/tmp --exclude=/media --exclude=/lost+found -c /