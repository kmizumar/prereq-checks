function check_database() {
    local VERSION_PATTERN='([0-9][0-9]*\.[0-9][0-9]*)\.[0-9][0-9]*'
    local mysql_ver=''
    local mysql_rpm=''
    local mysql_ent
    local mysql_com

    mysql_ent=$(rpm -q --queryformat='%{VERSION}' mysql-commercial-server)
    # shellcheck disable=SC2181
    if [[ $? -eq 0 ]]; then
        mysql_rpm=$(rpm -q mysql-commercial-server)
        [[ $mysql_ent =~ $VERSION_PATTERN ]]
        mysql_ver=${BASH_REMATCH[1]}
    fi

    mysql_com=$(rpm -q --queryformat='%{VERSION}' mysql-community-server)
    # shellcheck disable=SC2181
    if [[ $? -eq 0 ]]; then
        mysql_rpm=$(rpm -q mysql-community-server)
        [[ $mysql_com =~ $VERSION_PATTERN ]]
        mysql_ver=${BASH_REMATCH[1]}
    fi
    if [[ -z "$mysql_ver" ]]; then
        state "Database: MySQL server not installed, skipping version check" 2
        return
    fi

    case "$mysql_ver" in
        '5.1'|'5.5'|'5.6'|'5.7')
            state "Database: Supported MySQL server installed. $mysql_rpm" 0
            ;;
        *)
            state "Database: Unsupported MySQL server installed. $mysql_rpm" 1
            ;;
    esac
}
