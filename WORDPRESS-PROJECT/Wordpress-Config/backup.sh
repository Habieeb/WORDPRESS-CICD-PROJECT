#!/bin/bash

# Configuration
TIMESTAMP=$(date +"%F")
BACKUP_DIR="/backup/$TIMESTAMP"
MYSQL_USER="root"
MYSQL_PASSWORD="password"
MYSQL_HOST="mysql-container:3306"
MYSQL_DB="wordpress"

# Create the new backup directory
mkdir -p "$BACKUP_DIR"

# Delete the previous backup directory if it exists
# Find the latest backup directory, excluding the current one
LATEST_BACKUP=$(ls -1 /backup | grep -E "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" | sort | tail -n 1)

if [ -n "$LATEST_BACKUP" ] && [ "$LATEST_BACKUP" != "$TIMESTAMP" ]; then
    rm -rf "/backup/$LATEST_BACKUP"
fi

# Create the new database backup
mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" "$MYSQL_DB" > "$BACKUP_DIR/db_backup.sql"
