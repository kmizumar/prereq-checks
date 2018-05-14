function check_jdbc_connector() {
    # See Installing the MySQL JDBC Driver
    # https://www.cloudera.com/documentation/enterprise/latest/topics/cm_ig_mysql.html#cmig_topic_5_5_3
    local connector=/usr/share/java/mysql-connector-java.jar
    if [ -f $connector ]; then
        state "Database: MySQL JDBC Driver is installed" 0
    else
        state "Database: MySQL JDBC Driver is not installed" 2
    fi
}
