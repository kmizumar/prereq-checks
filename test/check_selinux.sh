#!/usr/bin/env bash

declare -r TESTEE='check_selinux'

function oneTimeSetUp() {
    cat <<EOS
--------------------------------------------------------------------------------
shUnit2 start version: ${SHUNIT_VERSION} tmpdir: ${SHUNIT_TMDIR}
testee: ${TESTEE}
--------------------------------------------------------------------------------
EOS
    . ../lib/utils.sh
    . ../lib/check_selinux.sh
}

function oneTimeTearDown() {
    cat <<EOS
--------------------------------------------------------------------------------
shUnit2 end
--------------------------------------------------------------------------------
EOS
}

function setUp() {
    :
}

function tearDown() {
    :
}

function suite() {
    suite_addTest test_check_selinux
}

# remove ANSI escape sequence(s)
function rmescseq() {
    echo "$1" | sed -re "s|\x1B\[[0-9;]*[mK]||g"
}

function test_check_selinux() {
    if is_centos_rhel_7; then
        result=$(rmescseq "$(check_selinux)")
        assertEquals "getenforce isn't included in CentOS7 image" \
                     " FAIL  System: 'getenforce' not found, skipping SELinux check. Run 'sudo yum install libselinux-utils' to fix."
        sudo yum install libselinux-utils -y
    fi
    result=$(rmescseq "$(check_selinux)")
    assertEquals "Checking SELinux" \
        ' PASS  System: SELinux should be disabled' "${result}"
}

. ../shunit2-2.1.7/shunit2
