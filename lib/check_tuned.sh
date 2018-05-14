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
