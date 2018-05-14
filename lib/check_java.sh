function check_java() {
    # The following candidate list is from CM agent:
    # Starship/cmf/agents/cmf/service/common/cloudera-config.sh
    local JAVA6_HOME_CANDIDATES=(
        '/usr/lib/j2sdk1.6-sun'
        '/usr/lib/jvm/java-6-sun'
        '/usr/lib/jvm/java-1.6.0-sun-1.6.0'
        '/usr/lib/jvm/j2sdk1.6-oracle'
        '/usr/lib/jvm/j2sdk1.6-oracle/jre'
        '/usr/java/jdk1.6'
        '/usr/java/jre1.6'
    )
    local OPENJAVA6_HOME_CANDIDATES=(
        '/usr/lib/jvm/java-1.6.0-openjdk'
        '/usr/lib/jvm/jre-1.6.0-openjdk'
    )
    local JAVA7_HOME_CANDIDATES=(
        '/usr/java/jdk1.7'
        '/usr/java/jre1.7'
        '/usr/lib/jvm/j2sdk1.7-oracle'
        '/usr/lib/jvm/j2sdk1.7-oracle/jre'
        '/usr/lib/jvm/java-7-oracle'
    )
    local OPENJAVA7_HOME_CANDIDATES=(
        '/usr/lib/jvm/java-1.7.0-openjdk'
        '/usr/lib/jvm/java-7-openjdk'
    )
    local JAVA8_HOME_CANDIDATES=(
        '/usr/java/jdk1.8'
        '/usr/java/jre1.8'
        '/usr/lib/jvm/j2sdk1.8-oracle'
        '/usr/lib/jvm/j2sdk1.8-oracle/jre'
        '/usr/lib/jvm/java-8-oracle'
    )
    local OPENJAVA8_HOME_CANDIDATES=(
        '/usr/lib/jvm/java-1.8.0-openjdk'
        '/usr/lib/jvm/java-8-openjdk'
    )
    local MISCJAVA_HOME_CANDIDATES=(
        '/Library/Java/Home'
        '/usr/java/default'
        '/usr/lib/jvm/default-java'
        '/usr/lib/jvm/java-openjdk'
        '/usr/lib/jvm/jre-openjdk'
    )
    local JAVA_HOME_CANDIDATES=(
        "${JAVA7_HOME_CANDIDATES[@]}"
        "${JAVA8_HOME_CANDIDATES[@]}"
        "${JAVA6_HOME_CANDIDATES[@]}"
        "${MISCJAVA_HOME_CANDIDATES[@]}"
        "${OPENJAVA7_HOME_CANDIDATES[@]}"
        "${OPENJAVA8_HOME_CANDIDATES[@]}"
        "${OPENJAVA6_HOME_CANDIDATES[@]}"
    )

    # Find and verify Java
    # https://www.cloudera.com/documentation/enterprise/release-notes/topics/rn_consolidated_pcm.html#pcm_jdk
    # JDK 7 minimum required version is JDK 1.7u55
    # JDK 8 minimum required version is JDK 1.8u31
    #   excluldes JDK 1.8u40, JDK 1.8u45, and JDK 1.8u60
    for candidate_regex in "${JAVA_HOME_CANDIDATES[@]}"; do
        # shellcheck disable=SC2045
        for candidate in $(ls -rvd "${candidate_regex}*" 2>/dev/null); do
            if [ -x "$candidate/bin/java" ]; then
                VERSION_STRING=$("$candidate"/bin/java -version 2>&1)
                RE_JAVA_GOOD='java[[:space:]]version[[:space:]]\"1\.([0-9])\.0_([0-9][0-9]*)\"'
                RE_JAVA_BAD='openjdk[[:space:]]version[[:space:]]\"1\.[0-9]\.'
                if [[ $VERSION_STRING =~ $RE_JAVA_GOOD ]]; then
                    if [[ ${BASH_REMATCH[1]} -eq 7 ]]; then
                        if [[ ${BASH_REMATCH[2]} -lt 55 ]]; then
                            state "Java: Unsupported Oracle Java: ${candidate}/bin/java" 1
                        else
                            state "Java: Supported Oracle Java: ${candidate}/bin/java" 0
                        fi
                    elif [[ ${BASH_REMATCH[1]} -eq 8 ]]; then
                        if [[ ${BASH_REMATCH[2]} -lt 31 ]]; then
                            state "Java: Unsupported Oracle Java: ${candidate}/bin/java" 1
                        elif [[ ${BASH_REMATCH[2]} -eq 40 ]]; then
                            state "Java: Unsupported Oracle Java: ${candidate}/bin/java" 1
                        elif [[ ${BASH_REMATCH[2]} -eq 45 ]]; then
                            state "Java: Unsupported Oracle Java: ${candidate}/bin/java" 1
                        elif [[ ${BASH_REMATCH[2]} -eq 60 ]]; then
                            state "Java: Unsupported Oracle Java: ${candidate}/bin/java" 1
                        else
                            state "Java: Supported Oracle Java: ${candidate}/bin/java" 0
                        fi
                    else
                        state "Java: Unsupported Oracle Java: ${candidate}/bin/java" 0
                    fi
                elif [[ $VERSION_STRING =~ $RE_JAVA_BAD ]]; then
                    state "Java: Unsupported OpenJDK: ${candidate}/bin/java" 1
                else
                    state "Java: Unsupported Unknown: ${candidate}/bin/java" 1
                fi
            fi
        done
    done
}
