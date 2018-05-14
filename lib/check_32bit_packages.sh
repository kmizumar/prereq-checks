function check_32bit_packages() {
    local packages_32bit
    packages_32bit=$(rpm -qa --queryformat '\t%{NAME} %{ARCH}\n' | grep 'i[6543]86' | cut -d' ' -f1)
    if [ "$packages_32bit" ]; then
        state "System: Found the following 32bit packages installed:\\n$packages_32bit" 1
    else
        state "System: Only 64bit packages should be installed" 0
    fi
}
