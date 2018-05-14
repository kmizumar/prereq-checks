# Networking Protocols Support
# CDH requires IPv4. IPv6 is not supported and must be disabled.
# https://www.cloudera.com/documentation/enterprise/release-notes/topics/rn_consolidated_pcm.html
function check_ipv6() {
    local msg="Network: IPv6 is not supported and must be disabled"
    if ip addr show | grep -q inet6; then
        state "${msg}" 1
    else
        state "${msg}" 0
    fi
}
