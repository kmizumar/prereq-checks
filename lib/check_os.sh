function check_os() {
    function check_swappiness() {
        # http://www.cloudera.com/content/www/en-us/documentation/enterprise/latest/topics/cdh_admin_performance.html#xd_583c10bfdbd326ba-7dae4aa6-147c30d0933--7fd5__section_xpq_sdf_jq
        local swappiness
        local msg="System: /proc/sys/vm/swappiness should be 1"
        swappiness=$(cat /proc/sys/vm/swappiness)
        if [ "$swappiness" -eq 1 ]; then
            state "$msg" 0
        else
            state "$msg. Actual: $swappiness" 1
        fi
    }

    function check_tuned() {
        # "tuned" service should be disabled on RHEL/CentOS 7.x
        # https://www.cloudera.com/documentation/enterprise/latest/topics/cdh_admin_performance.html#xd_583c10bfdbd326ba-7dae4aa6-147c30d0933--7fd5__disable-tuned
        if is_centos_rhel_7; then
            systemctl status tuned &>/dev/null
            case $? in
                0) state "System: tuned is running" 1;;
                3) state "System: tuned is not running" 0;;
                *) state "System: tuned is not installed" 0;;
            esac
            if [ "$(systemctl is-enabled tuned 2>/dev/null)" == "enabled" ]; then
                state "System: tuned auto-starts on boot" 1
            else
                state "System: tuned does not auto-start on boot" 0
            fi
        fi
    }

    function check_thp() {
        # Older RHEL/CentOS versions use [1], while newer versions (e.g. 7.1) and
        # Ubuntu/Debian use [2]:
        #   1: /sys/kernel/mm/redhat_transparent_hugepage/defrag
        #   2: /sys/kernel/mm/transparent_hugepage/defrag.
        # http://www.cloudera.com/content/www/en-us/documentation/enterprise/latest/topics/cdh_admin_performance.html#xd_583c10bfdbd326ba-7dae4aa6-147c30d0933--7fd5__section_hw3_sdf_jq
        local file
        file=$(find /sys/kernel/mm/ -type d -name '*transparent_hugepage')/defrag
        if [ -f "$file" ]; then
            local msg="System: $file should be disabled"
            if grep -Fq "[never]" "$file"; then
                state "$msg" 0
            else
                state "$msg. Actual: $(awk '{print $1}' "$file" | sed -e 's/\[//' -e 's/\]//')" 1
            fi
        else
            state "System: /sys/kernel/mm/*transparent_hugepage not found. Check skipped" 2
        fi
    }

    function check_selinux() {
        # http://www.cloudera.com/content/www/en-us/documentation/enterprise/latest/topics/install_cdh_disable_selinux.html
        local msg="System: SELinux should be disabled"
        case $(getenforce) in
            Disabled|Permissive) state "$msg" 0;;
            *)                   state "$msg. Actual: $(getenforce)" 1;;
        esac
    }

    # Check that the system clock is synced by either ntpd or chronyd. Chronyd
    # is on CentOS/RHEL 7 and above only.
    # https://community.cloudera.com/t5/Cloudera-Manager-Installation/Should-Cloudera-NTP-use-Chrony-or-NTPD/td-p/55986
    function check_time_sync() (
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
    )

    function check_32bit_packages() {
        local packages_32bit
        packages_32bit=$(rpm -qa --queryformat '\t%{NAME} %{ARCH}\n' | grep 'i[6543]86' | cut -d' ' -f1)
        if [ "$packages_32bit" ]; then
            state "System: Found the following 32bit packages installed:\\n$packages_32bit" 1
        else
            state "System: Only 64bit packages should be installed" 0
        fi
    }

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

    check_swappiness
    check_tuned
    check_thp
    check_selinux
    check_time_sync
    check_32bit_packages
    check_unneeded_services
    check_tmp_noexec
}
