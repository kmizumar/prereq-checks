function check_firewall() {
    # http://www.cloudera.com/content/www/en-us/documentation/enterprise/latest/topics/install_cdh_disable_iptables.html
    if is_centos_rhel_7; then
        _check_service_is_not_running 'Network' 'firewalld'
    else
        _check_service_is_not_running 'Network' 'iptables'
    fi
}
