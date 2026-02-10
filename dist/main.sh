#!/usr/bin/env bash
# Written in [Amber](https://amber-lang.com/)
# version: 0.5.1-alpha
array_find__0_v0() {
    local array=("${!1}")
    local value=$2
    index_18=0;
    for element_17 in "${array[@]}"; do
        if [ "$([ "_${value}" != "_${element_17}" ]; echo $?)" != 0 ]; then
            ret_array_find0_v0="${index_18}"
            return 0
        fi
        (( index_18++ )) || true
    done
    ret_array_find0_v0=-1
    return 0
}

array_contains__2_v0() {
    local array=("${!1}")
    local value=$2
    array_find__0_v0 array[@] "${value}"
    result_19="${ret_array_find0_v0}"
    ret_array_contains2_v0="$(( ${result_19} >= 0 ))"
    return 0
}

# We cannot import `bash_version` from `env.ab` because it imports `text.ab` making a circular dependency.
# This is a workaround to avoid that issue and the import system should be improved in the future.
bash_version__11_v0() {
    major_38="$(echo "${BASH_VERSINFO[0]}")"
    minor_39="$(echo "${BASH_VERSINFO[1]}")"
    command_2="$(echo "${BASH_VERSINFO[2]}")"
    __status=$?
    patch_40="${command_2}"
    ret_bash_version11_v0=("${major_38}" "${minor_39}" "${patch_40}")
    return 0
}

replace__12_v0() {
    local source=$1
    local search=$2
    local replace=$3
    # Here we use a command to avoid #646
    result_37=""
    bash_version__11_v0 
    left_comp=("${ret_bash_version11_v0[@]}")
    right_comp=(4 3)
    comp="$(
        # Compare if left array >= right array
        len_comp="$( (( "${#left_comp[@]}" < "${#right_comp[@]}" )) && echo "${#left_comp[@]}"|| echo "${#right_comp[@]}")"
        for (( i=0; i<len_comp; i++ )); do
            left="${left_comp[i]:-0}"
            right="${right_comp[i]:-0}"
            if (( "${left}" > "${right}" )); then
                echo 1
                exit
            elif (( "${left}" < "${right}" )); then
                echo 0
                exit
            fi
        done
        (( "${#left_comp[@]}" == "${#right_comp[@]}" || "${#left_comp[@]}" > "${#right_comp[@]}" )) && echo 1 || echo 0
)"
    if [ "${comp}" != 0 ]; then
        result_37="${source//"${search}"/"${replace}"}"
        __status=$?
    else
        result_37="${source//"${search}"/${replace}}"
        __status=$?
    fi
    ret_replace12_v0="${result_37}"
    return 0
}

__SED_VERSION_UNKNOWN_0=0
__SED_VERSION_GNU_1=1
__SED_VERSION_BUSYBOX_2=2
sed_version__14_v0() {
    # We can't match against a word "GNU" because
    # alpine's busybox sed returns "This is not GNU sed version"
    re='\bCopyright\b.+\bFree Software Foundation\b'; [[ $(sed --version 2>/dev/null) =~ $re ]]
    __status=$?
    if [ "$(( ${__status} == 0 ))" != 0 ]; then
        ret_sed_version14_v0="${__SED_VERSION_GNU_1}"
        return 0
    fi
    # On BSD single `sed` waits for stdin. We must use `sed --help` to avoid this.
    re='\bBusyBox\b'; [[ $(sed --help 2>&1) =~ $re ]]
    __status=$?
    if [ "$(( ${__status} == 0 ))" != 0 ]; then
        ret_sed_version14_v0="${__SED_VERSION_BUSYBOX_2}"
        return 0
    fi
    ret_sed_version14_v0="${__SED_VERSION_UNKNOWN_0}"
    return 0
}

split__16_v0() {
    local text=$1
    local delimiter=$2
    result_24=()
    IFS="${delimiter}" read -rd '' -a result_24 < <(printf %s "$text")
    __status=$?
    ret_split16_v0=("${result_24[@]}")
    return 0
}

trim_left__20_v0() {
    local text=$1
    command_6="$(echo "${text}" | sed -e 's/^[[:space:]]*//')"
    __status=$?
    ret_trim_left20_v0="${command_6}"
    return 0
}

trim_right__21_v0() {
    local text=$1
    command_7="$(echo "${text}" | sed -e 's/[[:space:]]*$//')"
    __status=$?
    ret_trim_right21_v0="${command_7}"
    return 0
}

trim__22_v0() {
    local text=$1
    trim_right__21_v0 "${text}"
    ret_trim_right21_v0__178_22="${ret_trim_right21_v0}"
    trim_left__20_v0 "${ret_trim_right21_v0__178_22}"
    ret_trim22_v0="${ret_trim_left20_v0}"
    return 0
}

parse_int__25_v0() {
    local text=$1
    [ -n "${text}" ] && [ "${text}" -eq "${text}" ] 2>/dev/null
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_parse_int25_v0=''
        return "${__status}"
    fi
    ret_parse_int25_v0="${text}"
    return 0
}

match_regex__31_v0() {
    local source=$1
    local search=$2
    local extended=$3
    sed_version__14_v0 
    sed_version_36="${ret_sed_version14_v0}"
    replace__12_v0 "${search}" "/" "\\/"
    search="${ret_replace12_v0}"
    output_41=""
    if [ "$(( $(( ${sed_version_36} == ${__SED_VERSION_GNU_1} )) || $(( ${sed_version_36} == ${__SED_VERSION_BUSYBOX_2} )) ))" != 0 ]; then
        # '\b' is supported but not in POSIX standards. Disable it
        replace__12_v0 "${search}" "\\b" "\\\\b"
        search="${ret_replace12_v0}"
    fi
    if [ "${extended}" != 0 ]; then
        # GNU sed versions 4.0 through 4.2 support extended regex syntax,
        # but only via the "-r" option
        if [ "$(( ${sed_version_36} == ${__SED_VERSION_GNU_1} ))" != 0 ]; then
            # '\b' is not in POSIX standards. Disable it
            replace__12_v0 "${search}" "\\b" "\\b"
            search="${ret_replace12_v0}"
            command_8="$(echo "${source}" | sed -r -ne "/${search}/p")"
            __status=$?
            output_41="${command_8}"
        else
            command_9="$(echo "${source}" | sed -E -ne "/${search}/p")"
            __status=$?
            output_41="${command_9}"
        fi
    else
        if [ "$(( $(( ${sed_version_36} == ${__SED_VERSION_GNU_1} )) || $(( ${sed_version_36} == ${__SED_VERSION_BUSYBOX_2} )) ))" != 0 ]; then
            # GNU Sed BRE handle \| as a metacharacter, but it is not POSIX standands. Disable it
            replace__12_v0 "${search}" "\\|" "|"
            search="${ret_replace12_v0}"
        fi
        command_10="$(echo "${source}" | sed -ne "/${search}/p")"
        __status=$?
        output_41="${command_10}"
    fi
    if [ "$([ "_${output_41}" == "_" ]; echo $?)" != 0 ]; then
        ret_match_regex31_v0=1
        return 0
    fi
    ret_match_regex31_v0=0
    return 0
}

dir_exists__47_v0() {
    local path=$1
    [ -d "${path}" ]
    __status=$?
    ret_dir_exists47_v0="$(( ${__status} == 0 ))"
    return 0
}

file_exists__48_v0() {
    local path=$1
    [ -f "${path}" ]
    __status=$?
    ret_file_exists48_v0="$(( ${__status} == 0 ))"
    return 0
}

dir_create__53_v0() {
    local path=$1
    dir_exists__47_v0 "${path}"
    ret_dir_exists47_v0__87_12="${ret_dir_exists47_v0}"
    if [ "$(( ! ${ret_dir_exists47_v0__87_12} ))" != 0 ]; then
        mkdir -p "${path}"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_dir_create53_v0=''
            return "${__status}"
        fi
    fi
}

is_mac_os_mktemp__54_v0() {
    # macOS's mktemp does not have --version
    mktemp --version >/dev/null 2>&1
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_is_mac_os_mktemp54_v0=1
        return 0
    fi
    ret_is_mac_os_mktemp54_v0=0
    return 0
}

temp_dir_create__55_v0() {
    local template=$1
    local auto_delete=$2
    local force_delete=$3
    trim__22_v0 "${template}"
    ret_trim22_v0__113_8="${ret_trim22_v0}"
    if [ "$([ "_${ret_trim22_v0__113_8}" != "_" ]; echo $?)" != 0 ]; then
        echo "The template cannot be an empty string"'!'""
        ret_temp_dir_create55_v0=''
        return 1
    fi
    filename_34=""
    is_mac_os_mktemp__54_v0 
    ret_is_mac_os_mktemp54_v0__119_8="${ret_is_mac_os_mktemp54_v0}"
    if [ "${ret_is_mac_os_mktemp54_v0__119_8}" != 0 ]; then
        # usage: mktemp [-d] [-p tmpdir] [-q] [-t prefix] [-u] template ...
        # mktemp [-d] [-p tmpdir] [-q] [-u] -t prefix
        command_11="$(mktemp -d -p "$TMPDIR" "${template}")"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_temp_dir_create55_v0=''
            return "${__status}"
        fi
        filename_34="${command_11}"
    else
        command_12="$(mktemp -d -p "$TMPDIR" -t "${template}")"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_temp_dir_create55_v0=''
            return "${__status}"
        fi
        filename_34="${command_12}"
    fi
    if [ "$([ "_${filename_34}" != "_" ]; echo $?)" != 0 ]; then
        echo "Failed to make a temporary directory"
        ret_temp_dir_create55_v0=''
        return 1
    fi
    if [ "${auto_delete}" != 0 ]; then
        if [ "${force_delete}" != 0 ]; then
            trap 'rm -rf '"${filename_34}"'' EXIT
            __status=$?
            if [ "${__status}" != 0 ]; then
                echo "Setting auto deletion fails. You must delete temporary dir ${filename_34}."
            fi
        else
            trap 'rmdir '"${filename_34}"'' EXIT
            __status=$?
            if [ "${__status}" != 0 ]; then
                echo "Setting auto deletion fails. You must delete temporary dir ${filename_34}."
            fi
        fi
    fi
    ret_temp_dir_create55_v0="${filename_34}"
    return 0
}

file_extract__61_v0() {
    local path=$1
    local target=$2
    file_exists__48_v0 "${path}"
    ret_file_exists48_v0__229_8="${ret_file_exists48_v0}"
    if [ "${ret_file_exists48_v0__229_8}" != 0 ]; then
        match_regex__31_v0 "${path}" "\\.(tar\\.bz2|tbz|tbz2)\$" 1
        ret_match_regex31_v0__231_13="${ret_match_regex31_v0}"
        match_regex__31_v0 "${path}" "\\.(tar\\.gz|tgz)\$" 1
        ret_match_regex31_v0__232_13="${ret_match_regex31_v0}"
        match_regex__31_v0 "${path}" "\\.(tar\\.xz|txz)\$" 1
        ret_match_regex31_v0__233_13="${ret_match_regex31_v0}"
        match_regex__31_v0 "${path}" "\\.bz2\$" 0
        ret_match_regex31_v0__234_13="${ret_match_regex31_v0}"
        match_regex__31_v0 "${path}" "\\.deb\$" 0
        ret_match_regex31_v0__235_13="${ret_match_regex31_v0}"
        match_regex__31_v0 "${path}" "\\.gz\$" 0
        ret_match_regex31_v0__236_13="${ret_match_regex31_v0}"
        match_regex__31_v0 "${path}" "\\.rar\$" 0
        ret_match_regex31_v0__237_13="${ret_match_regex31_v0}"
        match_regex__31_v0 "${path}" "\\.rpm\$" 0
        ret_match_regex31_v0__238_13="${ret_match_regex31_v0}"
        match_regex__31_v0 "${path}" "\\.tar\$" 0
        ret_match_regex31_v0__239_13="${ret_match_regex31_v0}"
        match_regex__31_v0 "${path}" "\\.xz\$" 0
        ret_match_regex31_v0__240_13="${ret_match_regex31_v0}"
        match_regex__31_v0 "${path}" "\\.7z\$" 0
        ret_match_regex31_v0__241_13="${ret_match_regex31_v0}"
        match_regex__31_v0 "${path}" "\\.\\(zip\\|war\\|jar\\)\$" 0
        ret_match_regex31_v0__242_13="${ret_match_regex31_v0}"
        if [ "${ret_match_regex31_v0__231_13}" != 0 ]; then
            tar xvjf "${path}" -C "${target}"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_file_extract61_v0=''
                return "${__status}"
            fi
        elif [ "${ret_match_regex31_v0__232_13}" != 0 ]; then
            tar xzf "${path}" -C "${target}"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_file_extract61_v0=''
                return "${__status}"
            fi
        elif [ "${ret_match_regex31_v0__233_13}" != 0 ]; then
            tar xJf "${path}" -C "${target}"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_file_extract61_v0=''
                return "${__status}"
            fi
        elif [ "${ret_match_regex31_v0__234_13}" != 0 ]; then
            bunzip2 "${path}"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_file_extract61_v0=''
                return "${__status}"
            fi
        elif [ "${ret_match_regex31_v0__235_13}" != 0 ]; then
            dpkg-deb -xv "${path}" "${target}"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_file_extract61_v0=''
                return "${__status}"
            fi
        elif [ "${ret_match_regex31_v0__236_13}" != 0 ]; then
            gunzip "${path}"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_file_extract61_v0=''
                return "${__status}"
            fi
        elif [ "${ret_match_regex31_v0__237_13}" != 0 ]; then
            unrar x "${path}" "${target}"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_file_extract61_v0=''
                return "${__status}"
            fi
        elif [ "${ret_match_regex31_v0__238_13}" != 0 ]; then
            rpm2cpio "${path}" | cpio -idm
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_file_extract61_v0=''
                return "${__status}"
            fi
        elif [ "${ret_match_regex31_v0__239_13}" != 0 ]; then
            tar xf "${path}" -C "${target}"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_file_extract61_v0=''
                return "${__status}"
            fi
        elif [ "${ret_match_regex31_v0__240_13}" != 0 ]; then
            xz --decompress "${path}"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_file_extract61_v0=''
                return "${__status}"
            fi
        elif [ "${ret_match_regex31_v0__241_13}" != 0 ]; then
            7z -y "${path}" -o "${target}"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_file_extract61_v0=''
                return "${__status}"
            fi
        elif [ "${ret_match_regex31_v0__242_13}" != 0 ]; then
            unzip "${path}" -d "${target}"
            __status=$?
            if [ "${__status}" != 0 ]; then
                ret_file_extract61_v0=''
                return "${__status}"
            fi
        else
            echo "Error: Unsupported file type"
            ret_file_extract61_v0=''
            return 3
        fi
    else
        echo "Error: File not found"
        ret_file_extract61_v0=''
        return 2
    fi
}

env_var_get__109_v0() {
    local name=$1
    command_13="$(echo ${!name})"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_env_var_get109_v0=''
        return "${__status}"
    fi
    ret_env_var_get109_v0="${command_13}"
    return 0
}

is_command__111_v0() {
    local command=$1
    [ -x "$(command -v "${command}")" ]
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_is_command111_v0=0
        return 0
    fi
    ret_is_command111_v0=1
    return 0
}

has_failed__115_v0() {
    local command=$1
    eval ${command} >/dev/null 2>&1
    __status=$?
    ret_has_failed115_v0="$(( ${__status} != 0 ))"
    return 0
}

file_download__160_v0() {
    local url=$1
    local path=$2
    is_command__111_v0 "curl"
    ret_is_command111_v0__14_9="${ret_is_command111_v0}"
    is_command__111_v0 "wget"
    ret_is_command111_v0__17_9="${ret_is_command111_v0}"
    is_command__111_v0 "aria2c"
    ret_is_command111_v0__20_9="${ret_is_command111_v0}"
    if [ "${ret_is_command111_v0__14_9}" != 0 ]; then
        curl -L -o "${path}" "${url}" >/dev/null 2>&1
        __status=$?
    elif [ "${ret_is_command111_v0__17_9}" != 0 ]; then
        wget "${url}" -P "${path}" >/dev/null 2>&1
        __status=$?
    elif [ "${ret_is_command111_v0__20_9}" != 0 ]; then
        aria2c "${url}" -d "${path}" >/dev/null 2>&1
        __status=$?
    else
        ret_file_download160_v0=''
        return 1
    fi
}

get_os__164_v0() {
    command_14="$(uname -s)"
    __status=$?
    if [ "${__status}" != 0 ]; then
        echo "Failed to determine OS type (using \`uname\` command)."
        exit 1
    fi
    os_type_14="${command_14}"
    if [ "$([ "_${os_type_14}" != "_Darwin" ]; echo $?)" != 0 ]; then
        ret_get_os164_v0="macos"
        return 0
    fi
    if [ "$([ "_${os_type_14}" == "_Linux" ]; echo $?)" != 0 ]; then
        echo "Unsupported OS type: ${os_type_14}"
        exit 1
    fi
    has_failed__115_v0 "ls -l /lib | grep libc.musl"
    ret_has_failed115_v0__21_10="${ret_has_failed115_v0}"
    if [ "$(( ! ${ret_has_failed115_v0__21_10} ))" != 0 ]; then
        ret_get_os164_v0="linux-musl"
        return 0
    fi
    ret_get_os164_v0="linux-gnu"
    return 0
}

get_arch__165_v0() {
    command_15="$(uname -m)"
    __status=$?
    if [ "${__status}" != 0 ]; then
        echo "Failed to determine architecture."
        exit 1
    fi
    arch_type_16="${command_15}"
    array_16=("arm64" "aarch64")
    array_contains__2_v0 array_16[@] "${arch_type_16}"
    ret_array_contains2_v0__34_14="${ret_array_contains2_v0}"
    arch_20="$(if [ "${ret_array_contains2_v0__34_14}" != 0 ]; then echo "aarch64"; else echo "x86_64"; fi)"
    ret_get_arch165_v0="${arch_20}"
    return 0
}

is_version_lt_0_5_0__166_v0() {
    local ver=$1
    # Remove -alpha, -beta, etc. suffix
    split__16_v0 "${ver}" "-"
    version_parts_25=("${ret_split16_v0[@]}")
    split__16_v0 "${version_parts_25[0]}" "."
    version_numbers_26=("${ret_split16_v0[@]}")
    # Parse major, minor, patch
    parse_int__25_v0 "${version_numbers_26[0]}"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_is_version_lt_0_5_0166_v0=0
        return 0
    fi
    major_27="${ret_parse_int25_v0}"
    __length_17=("${version_numbers_26[@]}")
    parse_int__25_v0 "${version_numbers_26[1]}"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_is_version_lt_0_5_0166_v0=0
        return 0
    fi
    ret_parse_int25_v0__50_10="${ret_parse_int25_v0}"
    minor_28="$(if [ "$(( ${#__length_17[@]} > 1 ))" != 0 ]; then echo "${ret_parse_int25_v0__50_10}"; else echo 0; fi)"
    # Compare with 0.5.0
    if [ "$(( ${major_27} < 0 ))" != 0 ]; then
        ret_is_version_lt_0_5_0166_v0=1
        return 0
    elif [ "$(( ${major_27} > 0 ))" != 0 ]; then
        ret_is_version_lt_0_5_0166_v0=0
        return 0
    else
        ret_is_version_lt_0_5_0166_v0="$(( ${minor_28} < 5 ))"
        return 0
    fi
}

check_url_exists__167_v0() {
    local url=$1
    max_retries_30=3
    retry_delay_seconds_31=1
    from=1
    to="$(( ${max_retries_30} + 1 ))"
    for attempt_32 in $(if [ "${from}" -gt "${to}" ]; then seq -- "${from}" -1 "$(( ${to} + 1 ))"; elif [ "${from}" -lt "${to}" ]; then seq -- "${from}" "$(( ${to} - 1 ))"; fi); do
        curl --head --fail --silent --location "${url}" >/dev/null 2>&1
        __status=$?
        code_33="${__status}"
            if [ "$(( ${code_33} == 0 ))" != 0 ]; then
                ret_check_url_exists167_v0=1
                return 0
            fi
        if [ "$(( ${attempt_32} < ${max_retries_30} ))" != 0 ]; then
            echo "::debug::Attempt ${attempt_32}/${max_retries_30} failed, retrying in ${retry_delay_seconds_31}s..."
            sleep ${retry_delay_seconds_31}
            __status=$?
        fi
    done
    echo "::debug::Failed to check URL after ${max_retries_30} attempts"
    ret_check_url_exists167_v0=0
    return 0
}

install_amber_binary__168_v0() {
    local source=$1
    local cache_path=$2
    local bin_path=$3
    echo "::debug::Copying amber binary to cache '${cache_path}/amber'"
    cp "${source}" "${cache_path}/amber"
    __status=$?
    if [ "${__status}" != 0 ]; then
    code_11="${__status}"
        echo "Failed to copy binary to cache (exit code: ${code_11})."
        exit 1
    fi
    echo "::debug::Installing amber binary to '${bin_path}'"
    install "${source}" "${bin_path}"
    __status=$?
    if [ "${__status}" != 0 ]; then
    code_12="${__status}"
        echo "Failed to install binary to '${bin_path}' (exit code: ${code_12})."
        exit 1
    fi
}

build_amber_from_source__169_v0() {
    local source_dir=$1
    local cache_path=$2
    local bin_path=$3
    echo "::debug::Building Amber from source in '${source_dir}'"
    echo "::debug::Building Amber with cargo in '${source_dir}'"
    cd "${source_dir}" && cargo build --release
    __status=$?
    if [ "${__status}" != 0 ]; then
    code_9="${__status}"
        echo "Failed to build Amber from source (exit code: ${code_9})."
        echo "Please ensure Rust and Cargo are properly installed in your environment."
        echo "You may need to set up Rust toolchain before using this action."
        exit 1
    fi
    built_binary_path_10="${source_dir}/target/release/amber"
    file_exists__48_v0 "${built_binary_path_10}"
    ret_file_exists48_v0__116_10="${ret_file_exists48_v0}"
    if [ "$(( ! ${ret_file_exists48_v0__116_10} ))" != 0 ]; then
        echo "Error: Built Amber binary not found at '${built_binary_path_10}'."
        echo "Build might have failed or the binary path is incorrect."
        exit 1
    fi
    install_amber_binary__168_v0 "${built_binary_path_10}" "${cache_path}" "${bin_path}"
    echo "::debug::Successfully installed Amber from source to ${bin_path}"
}

env_var_get__109_v0 "SETUP_AMBER_CACHE_PATH"
__status=$?
cache_path_3="${ret_env_var_get109_v0}"
env_var_get__109_v0 "SETUP_AMBER_BIN_PATH"
__status=$?
bin_path_4="${ret_env_var_get109_v0}"
env_var_get__109_v0 "SETUP_AMBER_REPOSITORY_URL"
__status=$?
env_var_get__109_v0 "SETUP_AMBER_REPOSITORY_REF"
__status=$?
repo_ref_6="${ret_env_var_get109_v0}"
env_var_get__109_v0 "SETUP_AMBER_SOURCE_DIR"
__status=$?
source_dir_7="${ret_env_var_get109_v0}"
file_exists__48_v0 "${cache_path_3}/amber"
ret_file_exists48_v0__133_4="${ret_file_exists48_v0}"
if [ "${ret_file_exists48_v0__133_4}" != 0 ]; then
    echo "::debug::Using cached amber binary"
    install "${cache_path_3}/amber" "${bin_path_4}"
    __status=$?
    if [ "${__status}" != 0 ]; then
    code_8="${__status}"
        echo "Failed to locate binary file to ${bin_path_4} with code ${code_8}."
        exit 1
    fi
else
    dir_create__53_v0 "${cache_path_3}"
    __status=$?
    __length_18="${repo_ref_6}"
    if [ "$(( ${#__length_18} > 0 ))" != 0 ]; then
        # If amber-repository-ref is provided, build from source
        build_amber_from_source__169_v0 "${source_dir_7}" "${cache_path_3}" "${bin_path_4}"
    else
        # Otherwise, proceed with downloading pre-built binaries
        env_var_get__109_v0 "SETUP_AMBER_VERSION"
        __status=$?
        ver_13="${ret_env_var_get109_v0}"
        echo "::debug::Downloading amber ${ver_13}"
        get_os__164_v0 
        os_15="${ret_get_os164_v0}"
        get_arch__165_v0 
        arch_21="${ret_get_arch165_v0}"
        # Determine filename based on version
        filename_22="amber"
        binary_in_subdir_23=0
        is_version_lt_0_5_0__166_v0 "${ver_13}"
        ret_is_version_lt_0_5_0166_v0__153_8="${ret_is_version_lt_0_5_0166_v0}"
        if [ "${ret_is_version_lt_0_5_0166_v0__153_8}" != 0 ]; then
            # < 0.5.0: amber-{arch}-{target}.tar.xz
            # - amber-aarch64-apple-darwin.tar.xz
            # - amber-aarch64-unknown-linux-gnu.tar.xz
            # - amber-x86_64-apple-darwin.tar.xz
            # - amber-x86_64-unknown-linux-gnu.tar.xz
            # - amber-x86_64-unknown-linux-musl.tar.xz
            filename_22+="-${arch_21}"
            if [ "$(( $([ "_${os_15}" != "_linux-gnu" ]; echo $?) || $([ "_${os_15}" != "_linux-musl" ]; echo $?) ))" != 0 ]; then
                filename_22+="-unknown-${os_15}"
            else
                filename_22+="-apple-darwin"
            fi
            binary_in_subdir_23=1
        else
            # >= 0.5.0: amber-{os}-{arch}.tar.xz
            # - amber-linux-gnu-aarch64.tar.xz
            # - amber-linux-gnu-x86_64.tar.xz
            # - amber-linux-musl-aarch64.tar.xz
            # - amber-linux-musl-x86_64.tar.xz
            # - amber-macos-aarch64.tar.xz
            # - amber-macos-x86_64.tar.xz
            filename_22+="-${os_15}-${arch_21}"
            binary_in_subdir_23=0
        fi
        url_29="https://github.com/amber-lang/amber/releases/download/${ver_13}/${filename_22}.tar.xz"
        # Check if URL exists before downloading
        check_url_exists__167_v0 "${url_29}"
        ret_check_url_exists167_v0__181_12="${ret_check_url_exists167_v0}"
        if [ "$(( ! ${ret_check_url_exists167_v0__181_12} ))" != 0 ]; then
            echo "Error: Release file not found at ${url_29}"
            echo "Please check if version ${ver_13} exists and is available for your platform (${os_15}, ${arch_21})."
            exit 1
        fi
        echo "::debug::Downloading from ${url_29}"
        temp_dir_create__55_v0 "amber_download.XXXXXXXXXX" 1 1
        __status=$?
        temp_dir_35="${ret_temp_dir_create55_v0}"
        file_download__160_v0 "${url_29}" "${temp_dir_35}/amber.tar.xz"
        __status=$?
        file_extract__61_v0 "${temp_dir_35}/amber.tar.xz" "${temp_dir_35}"
        __status=$?
        # Install binary based on directory structure
        binary_source_42="$(if [ "${binary_in_subdir_23}" != 0 ]; then echo "${temp_dir_35}/${filename_22}/amber"; else echo "${temp_dir_35}/amber"; fi)"
        install_amber_binary__168_v0 "${binary_source_42}" "${cache_path_3}" "${bin_path_4}"
        echo "::debug::Successfully installed amber ${ver_13} to ${bin_path_4}"
    fi
fi
echo "amber-path=${bin_path_4}" >> "$GITHUB_OUTPUT"
__status=$?
if [ "${__status}" != 0 ]; then
code_43="${__status}"
    echo "::warning::Failed to set amber-path output with code ${code_43}."
fi
