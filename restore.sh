#!/bin/bash

set -euo pipefail

restore_database() {
  local backup_file;
  backup_file=$(ls -t my-joomla-db-*.sql.gz 2>/dev/null | head -n1)

  if [[ -z "$backup_file" ]]; then
    printf "✖ No database backup file found\n" >&2
    return 1
  fi

  if ! gunzip < "$backup_file" | docker exec -i mysql-container sh -c 'exec mysql -uroot -pmy-secret-pw --force'; then
    printf "✖ Failed to restore database from file: %s\n" "$backup_file" >&2
    return 1
  fi

  printf "✔ Database restore completed successfully\n"
}

restore_files() {
  local archive_file;
  archive_file=$(ls -t joomla-files-*.tar.gz 2>/dev/null | head -n1)

  if [[ -z "$archive_file" ]]; then
    printf "✖ No site files backup archive found\n" >&2
    return 1
  fi

  if ! docker exec -i joomla-container sh -c 'tar -xz -C /var/www/html' < "$archive_file"; then
    printf "✖ Failed to extract site files from archive: %s\n" "$archive_file" >&2
    return 1
  fi

  printf "✔ Site files extracted successfully\n"
}

main() {
  printf "🔁 Starting full restore...\n"

  restore_database || return 1
  restore_files || return 1

  printf "✅ Full restore completed successfully\n"
}

main

