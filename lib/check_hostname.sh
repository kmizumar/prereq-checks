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
