#!/usr/bin/env bash
#
# Set up Doom Emacs configuration on a system
#

usage="
$(basename "$0") [--help] --install/--uninstall [--verbose]

Install/Remove Doom Emacs configuration from system

Arguments:
    --install    Set up ~/.emacs.d and ~/.doom.d with configuration contained
                 in this repo
    --uninstall  Remove ~/.emacs.d and ~/.doom.d

Examples:
    $(basename "$0") --install
        Installs
    $(basename "$0") --uninstall
        Uninstalls

"

# ==================== FORMATTING ====================
if [[ -t 1 ]]; then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_blue="$(tty_mkbold 34)"
tty_magenta="$(tty_mkbold 35)"
tty_red="$(tty_mkbold 31)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

shell_join()
{
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"
  do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

chomp()
{
  printf "%s" "${1/"$'\n'"/}"
}

debug()
{
  if [[ "${DEBUG}" -eq 1 ]]; then
    printf "${tty_bold}${tty_blue}DEBUG: %s${tty_reset}\n" "$(shell_join "$@")"
  fi
}

info()
{
  printf "${tty_bold}INFO: %s${tty_reset}\n" "$(shell_join "$@")"
}

warn()
{
  printf "${tty_bold}${tty_magenta}WARNING: %s${tty_reset}\n" "$(chomp "$1")"
}

error()
{
  printf "${tty_bold} ${tty_red}ERROR:%s${tty_reset}\n" "$(chomp "$1")"
  exit 1
}

# ==================== LOCAL HELPERS ====================
# Blocking wait for user input (negative answer exits)
user_input() {
  local ans save_state
  echo
  echo "Press ${tty_bold}RETURN${tty_reset}/${tty_bold}ENTER${tty_reset} to continue or any other key to abort:"
  save_state="$(/bin/stty -g)"
  /bin/stty raw -echo
  IFS='' read -r -n 1 -d '' "ans"
  /bin/stty "${save_state}"
  # we test for \r and \n because some stuff does \r instead
  if ! [[ "${ans}" == $'\r' || "${ans}" == $'\n' ]]
  then
    exit 1
  fi
}

determine_sourcedir(){
    emacsver=`emacs --version | awk 'NR==1{print $3}'`
    debug "Found Emacs version ${emacsver}"
    if (( $(echo "${emacsver} > 26" |bc -l) )); then
        sourcedir="./emacs29"
    else
        sourcedir="./emacs26"
    fi
    debug "Using source directory ${sourcedir}"
    eval "$1='${sourcedir}'"
}

# ==================== ACTUAL FUNCTIONALITY ====================
install_doom()
{
    # TODO: check if
    # emacs
    # spellcheck
    # ripgrep
    # are installed
    determine_sourcedir sourcedir
    if [[ -d "${emacsd}" ]]; then
        warn "Found existing ${emacsd}! Do you want to create a backup copy and continue?"
        user_input
        mv "${emacsd}" "${emacsdbkp}"
        debug "Renamed ${emacsd} to ${emacsdbkp}"
    fi
    if [[ -d "${doomd}" ]]; then
        warn "Found existing ${doomd}! Do you want to create a backup copy and continue?"
        user_input
        mv "${doomd}" "${doomdbkp}"
        debug "Renamed ${doomd} to ${doomdbkp}"
    fi
    info "Setting up ${emacsd}..."
    cp -r "${sourcedir}/.emacs.d" "${emacsd}"
    info "Done"
    info "Setting up ${doomd}..."
    cp -r "${sourcedir}/.doom.d" "${doomd}"
    info "Done"
    info "Running doom installer..."
    PATH="${emacsd}/bin:${PATH}"
    doom install
    info "Done"
    info "Remember to install Doom's fonts using"
    info "   M-x nerd-icons-install-fonts"
    info "ALL DONE"

    return 0
}

uninstall_doom()
{
    error "Not implemented yet"
    return 0
}

update_doom()
{
    determine_sourcedir sourcedir
    info "Updating config in ${doomd}..."
    cp "${sourcedir}/.doom.d/"* "${doomd}/"
    info "Done"
    return 0
}

# In case no input was found, print help message and exit
if [ "$1" = "" ]; then
    echo "$usage"
    exit 0
fi

# Parse any provided options
optArray=()
while :; do
    case "$1" in
        "")
            break
            ;;
        --help)
	        optArray+=("help")
            ;;
        --install)
	        optArray+=("install")
            ;;
        --uninstall)
	        optArray+=("uninstall")
            ;;
        --update)
	        optArray+=("update")
            ;;
        --verbose)
	        DEBUG=1
            ;;
        *)
            error "Unknown argument: $1"
            ;;
    esac
    shift
done

# Parse mutually exclusive CLI args
if [[ "${#optArray[@]}" -gt 1 ]]; then
    error "Too many options provided"
fi
if [[ "${#optArray[@]}" -lt 1 ]]; then
    error "At least one option required"
fi

# Set up local vars
emacsd="${HOME}/.emacs.d"
emacsdbkp="${HOME}/.emacs.d_backup"
doomd="${HOME}/.doom.d"
doomdbkp="${HOME}/.doom.d_backup"

# Execute appropriate function
option="${optArray[0]}"
if [[ "${option}" == "help" ]]; then
    echo "${usage}"
elif [[ "${option}" == "install" ]]; then
    install_doom
elif [[ "${option}" == "uninstall" ]]; then
    uninstall_doom
elif [[ "${option}" == "update" ]]; then
    update_doom
fi

exit 0
