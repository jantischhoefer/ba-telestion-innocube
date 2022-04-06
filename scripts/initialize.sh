#!/bin/sh

# Script to initialize the Telestion Project.
# Run it with your preferred shell.
# (c) WüSpace e. V.

REAL_PATH="$(realpath "$0")"
SCRIPT_DIR="$(dirname "$REAL_PATH")"
SCRIPT_NAME="$(basename "$REAL_PATH")"

. "${SCRIPT_DIR}/env.sh"

BANNER="Telestion Project Initializer (POSIX) $VERSION
(c) WüSpace e. V."

HELP_TEXT="$BANNER

A POSIX script to initialize your Telestion Project.

Usage: $SCRIPT_NAME <options>
Options:
    -g, --gradle-group-name <name>  the Gradle Group Name to use
    -u, --repo-user-name <name>     name of the user that owns the Git repository
    -n, --repo-name <name>          name of the Git repository
    -h, --help                      print this help
    --version                       print the version number of this tool

Exit codes:
   1 generic error code
   2 input/output error, missing arguments or no stdin in interactive mode
   3 project is already initialized
"

APPENDIX="${CL_BLD}The project has been successfully initialized.
Please commit the changes and push them to your remote:

  ${CL_MGN}git add .
  git commit -m \"feat: Initialize project\"
  git push

${CL_CYA}Telestion${CL_RST}${CL_BLD} wishes you happy hacking!${CL_RST}
"

# parse arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    -g|--gradle-group-name)
      [ "$#" -lt 2 ] && { printf 'Name required\n'; exit 2; }
      gradle_group_name="$2"; shift
      ;;
    -u|--repo-user-name)
      [ "$#" -lt 2 ] && { printf 'Name required\n'; exit 2; }
      repo_user_name="$2"; shift
      ;;
    -n|--repo-name)
      [ "$#" -lt 2 ] && { printf 'Name required\n'; exit 2; }
      repo_name="$2"; shift
      ;;
    -h|--help) print_help ;;
    --version) print_version ;;
    *) print_unknown_option "$1" ;;
  esac
  shift
done

print_banner
require_not_initialized

section 'Configuration'
# acquire missing/not explicity set information
if [ -n "$gradle_group_name" ]; then
  step "Gradle Group Name: $gradle_group_name"
else
  # cannot determine information automatically -> ask user
  require_connected_terminal
  step 'Gradle Group Name (e.g. de.wuespace.telestion.project.playground): ' no-lf
  read -r gradle_group_name
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
cd_root_project

section "Update README.md"

mv -f "$PROJECT_ROOT/README.project.md" "$PROJECT_ROOT/README.md"

PATTERN="##REPO_USER##"
FILES="$PROJECT_ROOT/application/docker-compose.yml
$PROJECT_ROOT/application/docker-compose.prod.yml
$PROJECT_ROOT/README.md"

section "Insert repository user: $PATTERN -> $repo_user_name"

for file in $FILES; do
  step "Update $file"
  sed -i "s/$PATTERN/${repo_user_name}/g" "$file"
done

PATTERN="##REPO_NAME##"
FILES="$PROJECT_ROOT/application/docker-compose.yml
$PROJECT_ROOT/application/docker-compose.prod.yml
$PROJECT_ROOT/application/Dockerfile
$PROJECT_ROOT/application/settings.gradle
$PROJECT_ROOT/README.md"

section "Insert repository name: $PATTERN -> $repo_name"

for file in $FILES; do
  step "Update $file"
  sed -i "s/$PATTERN/${repo_name}/g" "$file"
done

PATTERN="##GROUP_ID##"
FILES="$PROJECT_ROOT/application/build.gradle"

section "Insert Gradle Group Name: $PATTERN -> $gradle_group_name"

for file in $FILES; do
  step "Update $file"
  sed -i "s/$PATTERN/${gradle_group_name}/g" "$file"
done

section "Generate Application source files"

SRC_DIR="$PROJECT_ROOT/application/src/main/java"
FILES="$SRC_DIR/SimpleVerticle.java"
main_package_dir="$SRC_DIR/$(echo "$gradle_group_name" | sed -e 's/\./\//g')"

step "Create folder path: $main_package_dir"
mkdir -p "$main_package_dir"

for file in $FILES; do
  step "Move $file"
  mv "$file" "$main_package_dir/"
  step "Attach package path to Java source"
  sed -i "1s/^/package ${gradle_group_name};\n\n/" "$main_package_dir/$(basename "$file")"
done

section "Lock project"
set_initialization true

# shutdown
print_appendix
cd_start_cwd
