#!/bin/bash
minecraft_folder="/home/ubuntu/homelab/Minecraft/minecraft-data"
backup_folder="/home/ubuntu/homelab/Minecraft/mc-backups"
backup_file="$backup_folder/mc_backup_$(date +\%Y\%m\%d_\%H\%M).tar.gz"
tar -czf "$backup_file" -C "$minecraft_folder" .

echo "마인크래프트 서버 백업이 완료되었습니다. 백업 파일: $backup_file"