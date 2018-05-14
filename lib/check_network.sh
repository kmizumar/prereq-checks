function check_network() {

    function check_hostname() {
        local fqdn
        local short
        fqdn=$(hostname -f)
        short=$(hostname -s)

        # https://en.wikipedia.org/wiki/Hostname
        # Hostnames are composed of series of labels concatenated with dots, as are
        # all domain names. Each label must be from 1 to 63 characters long, and the
        # entire hostname (including delimiting dots but not a trailing dot) has a
        # maximum of 253 ASCII characters.
        local VALID_FQDN='^([a-z]([a-z0-9\-]{0,61}[a-z0-9])?\.)+[a-z]([a-z0-9\-]{0,61}[a-z0-9])?$'
        echo "$fqdn" | grep -Eiq "$VALID_FQDN"
        local valid_format=$?
        if [[ $valid_format -eq 0 && ${#fqdn} -le 253 ]]; then
            if [[ ${#short} -gt 15 ]]; then
                # Microsoft still recommends computer names less than or equal to 15 characters.
                # https://serverfault.com/questions/123343/is-the-netbios-limt-of-15-charactors-still-a-factor-when-naming-computers
                # https://technet.microsoft.com/en-us/library/cc731383.aspx
                # If hostname is longer than that, we cannot do SSSD or Centrify etc to
                # add the node to domain. Won't work well with Kerberos/AD.
                state "Network: Computer name should be <= 15 characters (NetBIOS restriction)" 1
            else
                if [[ "${fqdn//\.*/}" = "$short" ]]; then
                    if [[ $(echo "$fqdn" | grep '[A-Z]') = "" ]]; then
                        state "Network: Hostname looks good (FQDN, no uppercase letters)" 0
                    else
                        # Cluster hosts must have a working network name resolution system and
                        # correctly formatted /etc/hosts file. All cluster hosts must have properly
                        # configured forward and reverse host resolution through DNS.
                        # The /etc/hosts files must:
                        # - Not contain uppercase hostnames
                        # https://www.cloudera.com/documentation/enterprise/release-notes/topics/rn_consolidated_pcm.html#cm_cdh_compatibility
                        state "Network: Hostname should not contain uppercase letters" 1
                    fi
                else
                    state "Network: Hostname misconfiguration (shortname and host label of FQDN don't match)" 2
                fi
            fi
        else
            # Important
            # - The canonical name of each host in /etc/hosts `must' be the FQDN
            # - Do not use aliases, either in /etc/hosts or in configuring DNS
            # https://www.cloudera.com/documentation/enterprise/latest/topics/cdh_ig_networknames_configure.html
            state "Network: Malformed hostname is configured (consult RFC)" 1
        fi
    }

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

    function check_nscd_and_sssd() {
        _check_service_is_running 'Network' 'nscd'
        local nscd_running=${SERVICE_STATE['running']}
        _check_service_is_running 'Network' 'sssd' 2
        local sssd_running=${SERVICE_STATE['running']}

        if $nscd_running && $sssd_running; then
            # 7.8. USING NSCD WITH SSSD
            # SSSD is not designed to be used with the NSCD daemon.
            # Even though SSSD does not directly conflict with NSCD, using both services
            # can result in unexpected behavior, especially with how long entries are cached.
            # https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System-Level_Authentication_Guide/usingnscd-sssd.html

            # How-to: Deploy Apache Hadoop Clusters Like a Boss
            # Name Service Caching
            # If you’re running Red Hat SSSD, you’ll need to modify the nscd configuration;
            # with SSSD enabled, don’t use nscd to cache passwd, group, or netgroup information.
            # http://blog.cloudera.com/blog/2015/01/how-to-deploy-apache-hadoop-clusters-like-a-boss/
            # shellcheck disable=SC2013
            for cached in $(awk '/^[^#]*enable-cache.*yes/ { print $2 }' /etc/nscd.conf); do
                case $cached in
                    'passwd'|'group'|'netgroup')
                        state "Network: nscd should not cache $cached with sssd enabled" 1
                        ;;
                    *)
                        ;;
                esac
            done
            # shellcheck disable=SC2013
            for non_cached in $(awk '/^[^#]*enable-cache.*no/ { print $2 }' /etc/nscd.conf); do
                case $non_cached in
                    'passwd'|'group'|'netgroup')
                        state "Network: nscd shoud not cache $non_cached with sssd enabled" 0
                        ;;
                    *)
                        ;;
                esac
            done
        fi
    }

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

    check_ipv6
    check_hostname
    check_etc_hosts
    check_nscd_and_sssd
    check_dns
}
