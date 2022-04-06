#!/bin/sh

# Creates a setup zip file for the current release.
# (c) WüSpace e. V.

REAL_PATH="$(realpath "$0")"
SCRIPT_DIR="$(dirname "$REAL_PATH")"
SCRIPT_NAME="$(basename "$REAL_PATH")"

. "${SCRIPT_DIR}/env.sh"

BANNER="Telestion Project Setup Generator (POSIX) $VERSION
(c) WüSpace e. V."

HELP_TEXT="$BANNER

A POSIX script to create a setup zip file contains the necessary files to deploy
a Telestion application on a production server.

Usage: $SCRIPT_NAME <options>
Options:
    -m, --tmp-dir <path>    path to the temporary directory the creator should use
    -t, --tag <tag>         the tag to use during packaging (e.g. v0.8.1)
    -n, --repo-name <name>  name of the Git repository
    -h, --help              print this help
    --version               print the version number of this tool

Exit codes:
   1 generic error code
   2 input/output error, missing arguments or no stdin in interactive mode
   3 project is not initialized
"

# parse arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    -m|--tmp-dir)
      [ "$#" -lt 2 ] && { printf 'Path required\n'; exit 2; }
      tmp_dir="$2"; shift
      ;;
    -t|--tag)
      [ "$#" -lt 2 ] && { printf 'Tag required\n'; exit 2; }
      tag="$2"; shift
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
require_initialized

section 'Configuration'
# acquire missing/not explicity set information
if [ -z "$tmp_dir" ]; then
  tmp_dir="/tmp/telestion"
fi
cd_tmp_dir() {
  cd "$tmp_dir" || {
    error "Cannot change into temporary directory: $tmp_dir"
  }
}
step "Temporary directory: $tmp_dir"

if [ -z "$tag" ]; then
  tag="v$(get_current_version)"
fi
step "Tag: $tag"

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

section "Prepare directories"

package_name="$repo_name-$tag"
package_dir="$tmp_dir/$package_name"
output_dir="$PROJECT_ROOT/build"

if [ -e "$package_dir" ]; then
  step "Remove existing package directory"
  rm -r "$package_dir"
fi

step "Create temporary directory: $package_dir"
mkdir -p "$package_dir"

step "Create output directory: $output_dir"
mkdir -p "$output_dir"

section "Copy setup files"

setup_files="$PROJECT_ROOT/application/docker-compose.prod.yml
$PROJECT_ROOT/application/conf
$PROJECT_ROOT/application/data"

for file in $setup_files; do
  if [ -e "$file" ]; then
    step "Copy $file"
    cp -r "$file" "$package_dir/"
  else
    step "${CL_YEL}WARNING:${CL_RST} ${CL_BLD}$file does not exist"
  fi
done

step "Rename production docker-compose configuration"
mv "$package_dir/docker-compose.prod.yml" "$package_dir/docker-compose.yml"

PATTERN="##TAG##"
version="$(printf '%s\n' "$tag" | cut -c2-)"
step "Insert version into docker-compose.yml: $version"
sed -i "s/$PATTERN/${version}/g" "$package_dir/docker-compose.yml"

section "Finalization"

step "Compress setup"
cd_tmp_dir
zip -r "$package_name.zip" "$package_name/"
cd_root_project

# move compressed files
if [ -f "$output_dir/$package_name.zip" ]; then
  step "${CL_YEL}WARNING:${CL_RST} ${CL_BLD}Setup file already exist. Overwriting"
fi
step "Move compressed setup"
mv -f "$tmp_dir/$package_name.zip" "$output_dir/"

section "Finished"

APPENDIX="${CL_BLD}The setup has been successfully built. You can find it under:

  ${CL_YEL}build/$repo_name-$tag.zip${CL_RST}

${CL_BLD}Copy it to your production system and extract it with:

  ${CL_MGN}unzip $repo_name-$tag.zip

${CL_CYA}Telestion${CL_RST}${CL_BLD} wishes you happy monitoring!${CL_RST}
"

# shutdown
print_appendix
cd_start_cwd
