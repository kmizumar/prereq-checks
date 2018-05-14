function check_etc_hosts() {
    local entries
    entries=$(grep -cEv "^#|^ *$" /etc/hosts)
    local msg="Network: /etc/hosts entries should be <= 2 (use DNS). Actual: $entries"
    if [ "$entries" -le 2 ]; then
        local rc=0
        while read -r line; do
            entry=$(echo "$line" | grep -Ev "^#|^ *$")
            if [ ! "$entry" = "" ]; then
                set -- "$(echo "$line" | awk '{ print $1, $2 }')"
                if [ "$1" = "127.0.0.1" ] || [ "$1" = "::1" ] && [ "$2" = "localhost" ]; then
                    :
                else
                    rc=1
                fi
            fi
        done < /etc/hosts
        if [ "$rc" -eq 0 ]; then
            state "$msg" 0
        else
            state "${msg}, but has non localhost" 2
        fi
    else
        state "$msg" 2
    fi
}
