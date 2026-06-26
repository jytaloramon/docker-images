#!/bin/sh


DEFAULT_USER='healthcheck'
DEFAULT_HOST='127.0.0.1'
DEFAULT_PORT='18121'
DEFAULT_NAS_PORT_NUMBER='0'
DEFAULT_STATISTICS_TYPE='all'

: ${HEALTHCHECK_USER:="$DEFAULT_USER"}
: ${HEALTHCHECK_HOST:="$DEFAULT_HOST"}
: ${HEALTHCHECK_PORT:="$DEFAULT_PORT"}
: ${HEALTHCHECK_NAS_PORT_NUMBER:="$DEFAULT_NAS_PORT_NUMBER"}
: ${HEALTHCHECK_STATISTICS_TYPE:="$DEFAULT_STATISTICS_TYPE"}


show_help(){
cat >&2 << EOF
Description:
    Docker healthcheck script for FreeRADIUS.
    Authentication or retrieves server statistics support.

Usage:
    $(basename "$0")
        Alias for "$(basename "$0") use-status".

    $(basename "$0") use-status
        Perform the health check by retrieving internal server statistics.

    $(basename "$0") use-auth [radtest-options]
        Perform the health check using an authentication request.

    $(basename "$0") --help
        Display this help message.

Arguments:
    radtest-options
        Optional arguments passed directly to "radtest".

Environment variables:
    HEALTHCHECK_HOST
        Hostname, IP address, or FQDN of the target RADIUS server.
        Default: $DEFAULT_HOST

    HEALTHCHECK_NAS_PORT_NUMBER
        Value of the NAS-Port attribute.
        Used only with "use-auth".
        Default: $DEFAULT_NAS_PORT_NUMBER

    HEALTHCHECK_PASSWORD
        User password or path to a password file.
        Used only with "use-auth".

    HEALTHCHECK_PORT
        Target RADIUS port.
        Default: $DEFAULT_PORT

    HEALTHCHECK_STATISTICS_TYPE
        Value of the FreeRADIUS-Statistics-Type attribute.
        Used only with "use-status".
        Default: $DEFAULT_STATISTICS_TYPE

    HEALTHCHECK_SECRET
        Client shared secret or path to a file containing the secret.

    HEALTHCHECK_USER
        Username to authenticate.
        Used only with "use-auth".
        Default: $DEFAULT_USER
EOF
}

print_info(){
    echo "$@"
}

print_error(){
    echo "$@" >&2
    exit 1
}

read_secrets_file(){
    if [[ -n "$radius_secret" && -r "$radius_secret" ]]; then
        radius_secret="$(head -n 1 "$radius_secret")"
    fi

    if [[ -n "$radius_password" && -r "$radius_password" ]]; then
        radius_password="$(head -n 1 "$radius_password")"
    fi
}

_main(){
    if [[ "$#" -eq 1 && "$1" == '--help' ]]; then
        show_help
        exit 0
    fi

    run_cmd=''
    radius_secret="$HEALTHCHECK_SECRET"
    radius_password="$HEALTHCHECK_PASSWORD"

    read_secrets_file    
 
    if [[ "$#" -eq 0 || "$#" -eq 1 && "$1" == 'use-status' ]]; then
        run_cmd="echo \"FreeRADIUS-Statistics-Type = $HEALTHCHECK_STATISTICS_TYPE\" \
            | radclient -x '$HEALTHCHECK_HOST:$HEALTHCHECK_PORT' status '$radius_secret' &> /dev/null"
    fi

    if [[ "$1" == 'use-auth' ]]; then
        shift
        
        run_cmd="radtest $@ \
            '$HEALTHCHECK_USER' \
            '$radius_password' \
            '$HEALTHCHECK_HOST:$HEALTHCHECK_PORT' \
            $HEALTHCHECK_NAS_PORT_NUMBER \
            '$radius_secret' &> /dev/null"
    fi

    if [[ -z "$run_cmd" ]]; then
        print_error "Unrecognized command."
        exit 1
    fi

    eval $run_cmd

    [[ "$?" -eq 0 ]] \
        && print_info "The service is running [SUCCESS]." \
        || print_error "The service is not running [FAIL]."
}

_main $@
