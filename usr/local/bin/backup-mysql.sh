#!/bin/bash

export LC_ALL=C


parent_dir="/backups/mysql"
defaults_file="/etc/my.cnf.d/mariabackup.cnf"
#encryption_key_file="${parent_dir}/encryption_key"
todays_dir="${parent_dir}/$(date +%A)"
log_file="backup-progress.log"

check_parent_dir () {
if [ ! -d "$parent_dir" ]; then
  mkdir /backups
  echo Create Directory: "$parent_dir" > "${log_file}" 2>> "${log_file}"
  
fi
}


error () {
    printf "%s: %s\n" "$(basename "${BASH_SOURCE}")" "${1}" >&2
    exit 1
}

set_options () {
    # List the innobackupex arguments
    #declare -ga mariabackup_args=(
        #"--encrypt=AES256"
        #"--encrypt-key-file=${encryption_key_file}"
        #"--encrypt-threads=${processors}"
        #"--slave-info"
        #"--incremental"
        
    mariabackup_args=(
        "--defaults-file=${defaults_file}"
        "--extra-lsndir=${todays_dir}"
        "--backup"
        "--compress"
        "--stream=xbstream"
        "--parallel=${processors}"
        "--compress-threads=${processors}"
    )
    
    backup_type="full"

    
}



take_backup () {
	
    rm -Rf /backups/mysql
    mariabackup --backup --target-dir="${parent_dir}" > "${log_file}" 2>> "${log_file}"
	mariabackup --prepare --target-dir="${parent_dir}" >> "${log_file}" 2>> "${log_file}"
	
}

check_parent_dir && set_options && take_backup

if tail -1 "${log_file}" | grep -q "completed OK"; then
    sudo /usr/bin/tar -czvf /mnt/s3disk/mysql/backup.tar.gz -c "${parent_dir}" >> "${log_file}" 2>> "${log_file}"
    printf "Backup successful!\n"
   
else
    error "Backup failure! Check ${log_file} for more information"
fi