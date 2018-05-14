# Consistency check on forward (hostname to ip address) and
# reverse (ip address to hostname) resolutions.
# Note that an additional `.' in the PTR ANSWER SECTION.
function check_dns() {
    which dig 2&>/dev/null
    if [ $? -eq 2 ]; then
        state "Network: 'dig' not found, skipping DNS checks. Run 'sudo yum install bind-utils' to fix." 2
        return
    fi

    local fqdn
    local fwd_lookup
    local rvs_lookup
    fqdn=$(hostname -f)
    fwd_lookup=$(dig -4 "$fqdn" A +short)
    rvs_lookup=$(dig -4 -x "$fwd_lookup" PTR +short)
    if [[ "${fqdn}." = "$rvs_lookup" ]]; then
        state "Network: Consistent name resolution of $fqdn" 0
    else
        state "Network: Inconsistent name resolution of $fqdn. Check DNS configuration" 1
    fi
}
