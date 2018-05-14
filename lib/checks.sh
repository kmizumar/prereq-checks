function checks() {
    print_header "Prerequisite checks"
    reset_service_state
    check_os
    check_network
    check_firewall
    check_java
    check_database
    check_jdbc_connector
}
