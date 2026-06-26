#!/bin/sh
set -e


: ${RESILIENT_MODE_TIME:='0'}


show_help(){
cat >&2 << EOF
Description:
    Starts the FreeRADIUS server inside the container.

Usage:
    $(basename $0) [radiusd-options]
    $(basename $0) radiusd [radiusd-options]
    $(basename $0) --standbymode
    $(basename $0) --help

Variables:
    RESILIENT_MODE_TIME
        When greater than zero, the application will restart after the defined time (in second).
        Default: 0
EOF
}

print_info(){
    echo "$(date +"[%Y-%m-%d %H:%M:%S %z]") $@"
}

standby_mode(){
    print_info "Standby Mode"
    
    while true; do
        sleep "1m"
    done
}

_main(){
    if [[ "$#" -eq 1 ]]; then
        if [[ "$1" == '--help'  ]]; then
            show_help
            exit 0
        elif [[ "$1" == '--standbymode' ]]; then
            standby_mode
            exit 0
        fi        
    fi

    if [[ "$#" -eq 0 || "$1" != "${1#-}" ]]; then
        set -- radiusd -f "$@"
    fi
    
    if [[ "$1" == 'radiusd' && "$RESILIENT_MODE_TIME" -gt 0 ]]; then
        while true; do
            print_info "Running in resilient mode..."
            $@

            print_info "Restarting the application in $RESILIENT_MODE_TIME seconds..."
            sleep $RESILIENT_MODE_TIME
        done

        exit 0
    fi

    exec "$@"
}

_main "$@"
