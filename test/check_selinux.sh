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
    result=$(rmescseq "$(check_selinux)")
    assertEquals "" \
        ' PASS  System: SELinux should be disabled' "${result}"
}

. ../shunit2-2.1.7/shunit2
