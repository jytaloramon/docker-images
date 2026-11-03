#!/usr/bin/env sh
#
# Perform health check for LDAP server.
#

set -Eeo pipefail

# Default values
readonly DEFAULT_SERVER='ldap://localhost:389'
readonly DEFAULT_SEARCH_SCOPE='base'
readonly DEFAULT_TIMEOUT='3'

# Set variables
: ${HEALTHCHECK_SERVER:="${DEFAULT_SERVER}"}
: ${HEALTHCHECK_SEARCH_SCOPE:="${DEFAULT_SEARCH_SCOPE}"}
: ${HEALTHCHECK_TIMEOUT:="${DEFAULT_TIMEOUT}"}

#
# Display help message.
#
# Outputs:
#   Help message to stderr.
#
print_help() {
  cat >&2 << EOF
Description:
  Perform health check for LDAP server.

Usage:
  $(basename $0) [ldapsearch-options]
  $(basename $0) --help

Variables:
  HEALTHCHECK_SERVER:
    Server URI.
    Default: ${DEFAULT_SERVER}

  HEALTHCHECK_BIND_DN:
    Bind DN.
    If not set, an anonymous bind will be attempted.

  HEALTHCHECK_BIND_PASSWORD:
    Bind Password, or the path to a file containing the password.
    If not set, an anonymous bind will be attempted.

  HEALTHCHECK_SEARCH_BASE:
    Base DN for search.
    If not set, HEALTHCHECK_BIND_DN will be used.

  HEALTHCHECK_SEARCH_SCOPE:
    Search scope.
    Default: ${DEFAULT_SEARCH_SCOPE}

  HEALTHCHECK_TIMEOUT:
    Time limit for the search (in seconds).
    Default: ${DEFAULT_TIMEOUT}

EOF
}

#
# Main function.
#
_main(){
  if [ "$1" == "--help" ]; then
    print_help
    exit 0
  fi

  local add_args="$@"

  set -- \
    -H "${HEALTHCHECK_SERVER}" \
    -x

  # If defined, configure the bind DN and password.
  if [ -n "${HEALTHCHECK_BIND_DN}" ] && [ -n "${HEALTHCHECK_BIND_PASSWORD}" ]; then
    set -- \
      "$@" \
      -D "${HEALTHCHECK_BIND_DN}" \
      "$(test -f "${HEALTHCHECK_BIND_PASSWORD}" && echo "-y" || echo "-w")" \
      "${HEALTHCHECK_BIND_PASSWORD}"
  fi

  set -- \
    "$@" \
    -b "${HEALTHCHECK_SEARCH_BASE:-"${HEALTHCHECK_BIND_DN}"}" \
    -s "${HEALTHCHECK_SEARCH_SCOPE}" \
    -l "${HEALTHCHECK_TIMEOUT}"

  for arg in $add_args; do
    set -- "$@" "${arg}"
  done

  set -- \
    "$@" \
    '(objectClass=*)' \
    'dn'

  ldapsearch "$@" > /dev/null

  [ "$?" -eq 0 ] \
    && echo "Service running." \
    || echo "Service not running or unreachable."
}

_main "$@"
