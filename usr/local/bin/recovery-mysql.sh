#!/bin/bash

export LC_ALL=C

parent_dir="/tmp/recovery/mysql"
sourse_file="/mnt/s3disk/mysql/backup.tar.gz"
defaults_file="/etc/my.cnf.d/mariabackup.cnf"
#encryption_key_file="${parent_dir}/encryption_key"
todays_dir="${parent_dir}/$(date +%A)"
log_file="recovery-progress.log"

check_parent_dir () {
if [ ! -d "$parent_dir" ]; then
  mkdir /tmp/recovery
  mkdir /tmp/recovery/mysql
  echo Create Directory: "$parent_dir" > "${log_file}" 2>> "${log_file}"
  fi
}


error () {
    printf "%s: %s\n" "$(basename "${BASH_SOURCE}")" "${1}" >&2
    exit 1
}



take_recovery () {
if [ ! -f "$sourse_file" ]; then	
    echo "$sourse_file" not found !!!
else
    echo Recoveryng...
	tar xvpfz "$sourse_file" -C "$parent_dir" > "${log_file}" 2>> "${log_file}"
	rm -r /var/lib/mysql/*
	mariabackup --copy-back --target-dir="$parent_dir"/backups/mysql > "${log_file}" 2>> "${log_file}"
fi
	
	
}

check_parent_dir && take_recovery

if tail -1 "${log_file}" | grep -q "completed OK"; then
    chown -R mysql:mysql /var/lib/mysql/
	sudo systemctl restart mariadb.service
    printf "Recovering successful!\n"
   
else
    error "Backup failure! Check ${log_file} for more information"
fi