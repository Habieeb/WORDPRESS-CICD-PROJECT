#!/bin/bash

# Configuration
TIMESTAMP=$(date +"%F")
BACKUP_DIR="/backup/$TIMESTAMP"
MYSQL_USER="root"
MYSQL_PASSWORD="password"
MYSQL_HOST="mysql-container"
MYSQL_PORT="3306"
MYSQL_DB="wordpress"

# Create the new backup directory
mkdir -p "$BACKUP_DIR" || { echo "Failed to create backup directory"; exit 1; }

# Delete the previous backup directory if it exists
LATEST_BACKUP=$(ls -1 /backup | grep -E "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" | sort | tail -n 1)

if [ -n "$LATEST_BACKUP" ] && [ "$LATEST_BACKUP" != "$TIMESTAMP" ]; then
    echo "Removing old backup: /backup/$LATEST_BACKUP"
    rm -rf "/backup/$LATEST_BACKUP" || { echo "Failed to remove old backup"; exit 1; }
fi

# Create the new database backup
echo "Backing up database..."
mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" -P "$MYSQL_PORT" "$MYSQL_DB" > "$BACKUP_DIR/db_backup.sql" \
    && echo "Backup created successfully at $BACKUP_DIR/db_backup.sql" \
    || { echo "Failed to create backup"; exit 1; }

# Optional: Compress the backup
# gzip "$BACKUP_DIR/db_backup.sql"

# Log completion
echo "Backup process completed."
