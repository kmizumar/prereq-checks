function check_selinux() {
    which getenforce 2>&/dev/null
    if [ $? -eq 2 ]; then
        state "System: 'getenforce' not found, skipping SELinux check. Run 'sudo yum install libselinux-utils' to fix." 2
        return
    fi

    # http://www.cloudera.com/content/www/en-us/documentation/enterprise/latest/topics/install_cdh_disable_selinux.html
    local msg="System: SELinux should be disabled"
    case $(getenforce) in
        Disabled|Permissive) state "$msg" 0;;
        *)                   state "$msg. Actual: $(getenforce)" 1;;
    esac
}
