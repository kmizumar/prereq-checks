function check_unneeded_services() {
    local UNNECESSARY_SERVICES=(
        'bluetooth'
        'cups'
        'ip6tables'
        'postfix'
    )
    for service_name in "${UNNECESSARY_SERVICES[@]}"; do
        _check_service_is_not_running 'System' "$service_name" 2
    done
}
