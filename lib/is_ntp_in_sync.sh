function is_ntp_in_sync() {
    if [ "$(ntpstat | grep -c "synchronised to NTP server")" -eq 1 ]; then
        state "System: ntpd clock synced" 0
    else
        state "System: ntpd clock NOT synced. Check 'ntpstat'" 1
    fi
}
