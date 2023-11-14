#!/bin/bash

log-message() {
    LEVEL=${1:-"INFO"}
    MESSAGE=${2:-"No message was sent to log"}
    printf "\n%s: %s" "$LEVEL" "$MESSAGE"
}

vars-are-defined() {
    for var in "$@";
    do
    if [[ -z "$var" ]]; then
            log-message "ERROR" "Variable '$var' does not exist"
            return 1
        fi
    done
    return 0
}

programs-are-installed() {
    for program in "$@";
    do
        if ! type "$program" >/dev/null 2>&1; then
        # if command "$program" >/dev/null 2>&1; then
            log-message "Error" "The program '$program' is not installed or not in the PATH"
            return 1
        fi
    done
    return 0
}

arg-count-is-correct() {
    CURRENT_ARGS=$1
    EXPECTED_ARGS=$2
    if [ "$CURRENT_ARGS" -ne "$EXPECTED_ARGS" ]; then
        log-message "Error" "Expected $EXPECTED_ARGS but found $CURRENT_ARGS args"
        return 1
    fi
    return 0
}

they-exist() {
  # Checks files or folders for existence.
  [[ -z "$1" ]] && error "Usage: they-exist -files|-folders [\$1 \$2 \$3...]" && return 1
  local flag="-files"
  [[ "$1" =~ ^(-files|-folders)$ ]] && flag="$1" && shift
  for item in "$@"; do
    case "$flag" in
      -folders)
        ! [[ -d "$item" ]] && log-message "ERROR" "Directory $item does not exist" && return 1
        ;;
      -files)
        ! [[ -f "$item" ]] && log-message "ERROR" "File $item does not exist" && return 1
        ;;
    esac
  done
  return 0
}

files-exist() {
  eval "they-exist -files ${@}"
}

folders-exist() {
  eval "they-exist -folders ${@}"
}
