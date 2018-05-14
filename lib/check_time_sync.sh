# Check that the system clock is synced by either ntpd or chronyd. Chronyd
# is on CentOS/RHEL 7 and above only.
# https://community.cloudera.com/t5/Cloudera-Manager-Installation/Should-Cloudera-NTP-use-Chrony-or-NTPD/td-p/55986
function check_time_sync() {
    function is_ntp_in_sync() {
        if [ "$(ntpstat | grep -c "synchronised to NTP server")" -eq 1 ]; then
            state "System: ntpd clock synced" 0
        else
            state "System: ntpd clock NOT synced. Check 'ntpstat'" 1
        fi
    }

    if is_centos_rhel_7; then
        get_service_state 'ntpd'
        if [ "${SERVICE_STATE['running']}" = true ]; then
            # If ntpd is running, then chrony shouldn't be
            _check_service_is_running 'System' 'ntpd'
            is_ntp_in_sync
            _check_service_is_not_running 'System' 'chronyd'
        else
            _check_service_is_running 'System' 'chronyd'
        fi
    else
        _check_service_is_running 'System' 'ntpd'
    fi
}
