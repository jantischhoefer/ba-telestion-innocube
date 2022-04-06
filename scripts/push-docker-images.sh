#!/bin/sh

# Creates and pushes docker images to the selected docker registry.
# (c) WüSpace e. V.

REAL_PATH="$(realpath "$0")"
SCRIPT_DIR="$(dirname "$REAL_PATH")"
SCRIPT_NAME="$(basename "$REAL_PATH")"

. "${SCRIPT_DIR}/env.sh"

BANNER="Telestion Project Docker Push Service (POSIX) $VERSION
(c) WüSpace e. V."

HELP_TEXT="$BANNER

A POSIX script to create and push docker images containing the application
that you want to deploy on your production server.

Usage: $SCRIPT_NAME <options>
Options:
    -u, --repo-user-name <name>  name of the user that owns the Git repository
    -n, --repo-name <name>       name of the Git repository
    -t, --tag <tag>              the tag to use during creation (e.g. v0.8.1)
    -d, --docker-registry        domain name of the docker registry to use (defaults to: docker hub domain)
    -h, --help                   print this help
    --version                    print the version number of this tool

Exit codes:
   1 generic error
   2 input/output error, missing arguments or no stdin in interactive mode
"

# parse arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    -u|--repo-user-name)
      [ "$#" -lt 2 ] && { printf 'Name required\n'; exit 2; }
      repo_user_name="$2"; shift
      ;;
    -n|--repo-name)
      [ "$#" -lt 2 ] && { printf 'Name required\n'; exit 2; }
      repo_name="$2"; shift
      ;;
    -t|--tag)
      [ "$#" -lt 2 ] && { printf 'Tag required\n'; exit 2; }
      version="$(printf '%s\n' "$2" | cut -c2-)"; shift
      ;;
    -d|--docker-registry)
      [ "$#" -lt 2 ] && { printf 'Docker registry domain required\n'; exit 2; }
      docker_registry="$2"; shift
      ;;
    -h|--help) print_help ;;
    --version) print_version ;;
    *) print_unknown_option "$1" ;;
  esac
  shift
done

print_banner
require_initialized

section 'Configuration'
# acquire missing/not explicity set information
if [ -z "$version" ]; then
  version="$(get_current_version)"
fi
step "Project version: $version"

if [ -z "$docker_registry" ]; then
  docker_registry_desc="docker.io"
  docker_registry=""
else
  docker_registry_desc="$docker_registry"
  docker_registry="$docker_registry/"
fi
step "Docker registry: $docker_registry_desc"

if docker info > /dev/null 2>&1; then
  SUDO=""
  step "Docker access rights: granted"
else
  # user don't has access rights -> try with sudo
  SUDO="sudo "
  if $SUDO docker info > /dev/null 2>&1; then
    step "Docker access rights: via sudo"
  else
    step "Docker access rights: restricted"
    error "Require access to docker. Please give your user docker access or run this script as root" 1
  fi
fi

if [ -n "$repo_user_name" ] || repo_user_name="$(get_git_repo_user)"; then
  step "Repository user: $repo_user_name"
else
  # cannot determine information automatically -> ask user
  require_connected_terminal
  step "Repository user (e.g. wuespace): " no-lf
  read -r repo_user_name
fi

if [ -n "$repo_name" ] || repo_name="$(get_git_repo_name)"; then
  step "Repository name: $repo_name"
else
  # cannot determine information automatically -> ask user
  require_connected_terminal
  step "Repository name (e.g. my-telestion-project): " no-lf
  read -r repo_name
fi

# startup
cd_application

section "Docker build"

step "Build and tag docker image"

major="$(printf '%s\n' "$version" | cut -d"." -f1)"
minor="$(printf '%s\n' "$version" | cut -d"." -f2)"
patch="$(printf '%s\n' "$version" | cut -d"." -f3)"

latest_tag="${docker_registry}${repo_user_name}/${repo_name}:latest"
major_tag="${docker_registry}${repo_user_name}/${repo_name}:${major}"
minor_tag="${docker_registry}${repo_user_name}/${repo_name}:${major}.${minor}"
patch_tag="${docker_registry}${repo_user_name}/${repo_name}:${major}.${minor}.${patch}"

if ! $SUDO docker build . --tag "$latest_tag" --tag "$major_tag" --tag "$minor_tag" --tag "$patch_tag"; then
  error "Cannot build docker image" 1
fi

section "Docker push"

step "Push latest tag"

if ! $SUDO docker push "$latest_tag"; then
  error "Cannot publish latest tag to registry" 1
fi

step "Push major tag"

if ! $SUDO docker push "$major_tag"; then
  error "Cannot publish latest tag to registry" 1
fi

step "Push minor tag"

if ! $SUDO docker push "$minor_tag"; then
  error "Cannot publish latest tag to registry" 1
fi

step "Push patch tag"

if ! $SUDO docker push "$patch_tag"; then
  error "Cannot publish latest tag to registry" 1
fi

section "Finished"

APPENDIX="${CL_BLD}Your project has been successfully pushed to the registry:

  ${CL_YEL}${docker_registry_desc}${CL_RST}

${CL_BLD}Create a setup file with the \"create-setup.sh\" script and copy it
over to your production system.

${CL_CYA}Telestion${CL_RST}${CL_BLD} wishes you happy monitoring!${CL_RST}
"

# shutdown
print_appendix
cd_start_cwd
