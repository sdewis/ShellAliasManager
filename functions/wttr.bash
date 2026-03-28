wttr() {
    local location="${1:-}"
    if [ -z "$location" ]; then
        curl -s "wttr.in?m"
    else
        curl -s "wttr.in/$location?m"
    fi
}
