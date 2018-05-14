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
