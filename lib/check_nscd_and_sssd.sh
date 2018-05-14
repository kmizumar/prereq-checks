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
