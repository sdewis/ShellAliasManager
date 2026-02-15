sync_backup() {
    print_status "Checking backup health..."
    local last_push=$(git log -1 --format=%ct 2>/dev/null || echo 0)
    local diff=$(( ($(date +%s) - last_push) / 86400 ))

    [[ "$diff" -ge 3 ]] && echo -e "${YELLOW}⚠️  Backup is $diff days old!${RESET}"

    git add . && git commit -m "Auto-sync: $(date)" && git push origin main
    echo -e "${GREEN}✔ Private backup synced successfully.${RESET}"
}
