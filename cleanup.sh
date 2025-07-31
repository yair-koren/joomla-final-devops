#!/bin/bash

cleanup_backups() {
  local db_pattern="my-joomla-db-*.sql.gz"
  local files_pattern="joomla-files-*.tar.gz"
  local db_backups; db_backups=$(find . -maxdepth 1 -name "$db_pattern" | sort -r)
  local file_backups; file_backups=$(find . -maxdepth 1 -name "$files_pattern" | sort -r)

  if [[ -z "$db_backups" && -z "$file_backups" ]]; then
    printf "ℹ️  No backup files found to clean.\n"
    return
  fi

  printf "🧹 Cleaning up old backup files...\n"

  printf "%s\n" "$db_backups" | tail -n +2 | xargs -r rm -f
  printf "%s\n" "$file_backups" | tail -n +2 | xargs -r rm -f

  printf "✅ Cleanup complete. Only latest backups retained.\n"
}

main() {
  cleanup_backups
}

main

