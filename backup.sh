#!/bin/bash

set -euo pipefail

log() {
    printf "✅ %s\n" "$1"
}

err() {
    printf "❌ %s\n" "$1" >&2
    exit 1
}

# קובץ גיבוי מסד נתונים
db_file="my-joomla-db-$(date +%Y%m%d_%H%M).sql.gz"
docker exec mysql-container sh -c 'exec mysqldump --all-databases -uroot -pmy-secret-pw' | gzip > "$db_file" || err "Database backup failed"
log "Database backup saved to $db_file"

# קובץ גיבוי קבצי האתר
site_file="joomla-files-$(date +%Y%m%d_%H%M).tar.gz"
if ! tar -czf "$site_file" -C /var/www/html .; then
    err "Failed to archive site files"
fi
log "Joomla files backup saved to $site_file"

# בדיקה שהקובץ נוצר תקין
if ! tar -tzf "$site_file" >/dev/null; then
    err "Archive validation failed: $site_file"
fi
log "Archive validation passed"

log "Backup complete."

