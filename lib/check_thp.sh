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
