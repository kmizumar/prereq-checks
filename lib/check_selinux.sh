function check_selinux() {
    # http://www.cloudera.com/content/www/en-us/documentation/enterprise/latest/topics/install_cdh_disable_selinux.html
    local msg="System: SELinux should be disabled"
    case $(getenforce) in
        Disabled|Permissive) state "$msg" 0;;
        *)                   state "$msg. Actual: $(getenforce)" 1;;
    esac
}
