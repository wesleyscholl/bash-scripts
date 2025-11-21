#!/bin/bash
# Script to backup system files weekly

# Set backup directories and files 
backup_dir="/var/backups"
backup_files="/etc /var/www /home /var/lib /var/mail /opt"

# Set the date and time for the backup
day=$(date +%Y-%m-%d)
hostname=$(hostname -s)
archive_file="$hostname-$day.tgz"

# Create the backup directory if it does not exist
if [ ! -d $backup_dir ]; then
  mkdir -p $backup_dir
fi

# Create the backup archive
tar czf $backup_dir/$archive_file $backup_files

# Print the backup status
echo "Backup of $backup_files completed! Details about the output backup file:"
ls -lh $backup_dir/$archive_file
echo "Backup completed on $(date)"
echo "Backup script completed"