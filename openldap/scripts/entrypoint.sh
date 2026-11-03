#!/usr/bin/env sh
#
# Entrypoint script for OpenLDAP image.
#

set -Eeo pipefail

# Default values
readonly DEFAULT_CONFIG_DIR='/etc/openldap'
readonly DEFAULT_DEBUG_LEVEL='0'

# Set variables
: ${OLDAP_CONFIG_DIR:="${DEFAULT_CONFIG_DIR}"}
: ${OLDAP_DEBUG_LEVEL:="${DEFAULT_DEBUG_LEVEL}"}

#
# Display help message.
#
# Outputs:
#   Help message to stderr.
#
print_help() {
  cat >&2 <<END
Description:
  Entrypoint script for OpenLDAP image.
  Starts the OpenLDAP server.

Usage:
  $(basename "$0") [slapd-options]
  $(basename "$0") {--help | <command> [args...]}

Variables:
  OLDAP_CONFIG_DIR:
    The directory where the OpenLDAP configuration files are located.
    Default: ${DEFAULT_CONFIG_DIR}

  OLDAP_DEBUG_LEVEL:
    The debug level for the OpenLDAP server.
    Default: ${DEFAULT_DEBUG_LEVEL}

END
}

#
# Main function.
#
_main() {
  if [ "$1" == "--help" ]; then
    print_help
    exit 0
  fi

  if [ "$#" -eq 0 ] || [ "$1" != "${1#"-"}" ]; then
    set -- "slapd" \
      "-d" \
      "${OLDAP_DEBUG_LEVEL}" \
      "-F" \
      "${OLDAP_CONFIG_DIR}" \
      "$@"
  fi

  exec "$@"
}

_main "$@"
