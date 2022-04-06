#!/bin/sh

VERSION="0.1"

PROJECT_ROOT="$(realpath "$(dirname "$REAL_PATH")/..")"
LOCK_FILE="$PROJECT_ROOT/.github/initialized"
START_CWD="$(pwd)"

if tput colors > /dev/null 2>&1; then
  CL_RST="$(tput sgr0)"
  CL_BLD="$(tput bold)"
  CL_RED="$(tput setaf 1)"
  CL_GRN="$(tput setaf 2)"
  CL_YEL="$(tput setaf 3)"
  CL_BLU="$(tput setaf 4)"
  CL_MGN="$(tput setaf 5)"
  CL_CYA="$(tput setaf 6)"
else
  CL_RST=""
  CL_BLD=""
  CL_RED=""
  CL_GRN=""
  CL_YEL=""
  CL_BLU=""
  CL_MGN=""
  CL_CYA=""
fi

##
## basic IO functions
##

# $1 - error message
# $2 - exit code
error() {
  msg="$1"
  exit_code="$2"

  printf "${CL_BLD}${CL_RED}==> ERROR:${CL_RST} ${CL_BLD}%s${CL_RST}\n" "$msg"
  exit "$exit_code"
}

# $1 - section name
section() {
  name="$1"
  printf "${CL_BLD}${CL_GRN}==>${CL_RST} ${CL_BLD}%s${CL_RST}\n" "$name"
}

# $1 - step name
# $2 - when set no LF
step() {
  name="$1"
  if [ -z "$2" ]; then
    printf "   ${CL_BLD}${CL_BLU}->${CL_RST} ${CL_BLD}%s${CL_RST}\n" "$name"
  else
    printf "   ${CL_BLD}${CL_BLU}->${CL_RST} ${CL_BLD}%s${CL_RST}" "$name"
  fi
}

##
## complex IO functions
##

print_help() {
  printf '%s\n' "$HELP_TEXT"
  exit 0
}

print_version() {
  printf '%s\n' "$VERSION"
  exit 0
}

print_banner() {
  printf "${CL_BLD}%s${CL_RST}\n\n" "$BANNER"
}

# $1 - unknown option
print_unknown_option() {
  printf 'Unknown option: %s\n' "$1"
  exit 2
}

require_connected_terminal() {
  if ! [ -t 0 ]; then
    error 'No terminal connected, cannot ask interactively' 2
  fi
}

print_appendix() {
  printf '\n%s\n' "$APPENDIX"
}

##
## project interaction
##

require_not_initialized() {
  if [ -f "$LOCK_FILE" ]; then
    error 'Project is already initialized' 3
  fi
}

require_initialized() {
  if ! [ -f "$LOCK_FILE" ]; then
    error 'Project is not yet initialized, use the "initialize.sh" script and try again' 3
  fi
}

# $1 - true/false to activate/deactivate initialization
set_initialization() {
  state="$1"
  if [ "$state" = "true" ]; then
    printf 'This project was initialized with Github Actions\n' > "$LOCK_FILE"
  else
    rm "$LOCK_FILE" > /dev/null 2>&1
  fi
}

get_current_version() {
  cat "$PROJECT_ROOT/version.txt"
}

##
## current working directory
##

cd_root_project() {
  cd "$PROJECT_ROOT" || {
    error "Cannot change into project root directory: $PROJECT_ROOT" 1
  }
}

cd_application() {
  cd "$PROJECT_ROOT/application" || {
    error "Cannot change into application directory: $PROJECT_ROOT/application" 1
  }
}

cd_start_cwd() {
  cd "$START_CWD" || {
    error "Cannot switch back to initial current working directory: $old_cwd, exiting uncleanly" 1
  }
}

##
## Git interaction
##

get_git_repo_user() {
  if ! git status > /dev/null 2>&1; then
    error 'Not in a git repository. Specify repository user manually with \"--repo-user-name <name>\" or create a repository with \"git init\"' 2
  fi

  # first remote wins
  remote="$(git remote show 2> /dev/null | head -n 1)"
  if [ -z "$remote" ]; then
    return 1
  fi

  if ! user="$(git remote get-url "$remote" | awk -F "/" '{print $(NF-1)}' | awk -F ":" '{print $NF}')"; then
    return 1
  fi
  printf '%s\n' "$user"
  return 0
}

get_git_repo_name() {
  if ! git status > /dev/null 2>&1; then
    error 'Not in a git repository. Specify repository user manually with \"--repo-user-name <name>\" or create a repository with \"git init\"' 2
  fi

  # first remote wins
  remote="$(git remote show 2> /dev/null | head -n 1)"
  if [ -z "$remote" ]; then
    return 1
  fi

  if ! name="$(git remote get-url "$remote" | awk -F "/" '{print $NF}' | cut -d"." -f1)"; then
    return 1
  fi
  printf '%s\n' "$name"
  return 0
}
