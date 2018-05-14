function check_tmp_noexec() {
    local noexec=false
    for option in $(findmnt -lno options --target /tmp | tr ',' ' '); do
        if [[ "$option" = 'noexec' ]]; then
            noexec=true
        fi
    done
    if $noexec; then
        state "System: /tmp mounted with noexec fails for CM versions older than 5.8.4, 5.9.2, and 5.10.0" 2
    else
        state "System: /tmp mounted with noexec fails for CM versions older than 5.8.4, 5.9.2, and 5.10.0" 0
    fi
}
