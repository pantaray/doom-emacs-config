#!/usr/bin/env bash
#
# Set up Doom Emacs configuration on a system
#

usage="
$(basename "$0") [--help] --install/--uninstall/--update [--verbose]

Install/Remove/Update Doom Emacs configuration

Arguments:
    --install    Set up ~/.emacs.d and ~/.doom.d with configuration contained
                 in this repo
    --uninstall  Remove ~/.emacs.d and ~/.doom.d
    --update     Update contents of ~/.emacs.d and ~/.doom.d

Examples:
    $(basename "$0") --install
        Installs
    $(basename "$0") --uninstall
        Uninstalls
    $(basename "$0") --update
        Updates an existing Doom Emacs installation

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
user_input()
{
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

# Blocking wait for user yes/no (negative answer does not exit script):
# YES = 1, NO = 0
user_yesno()
{
  local yn
  while true; do
      read -p "$* [y/n]: " yn
      case "${yn}" in
          [Yy]*) return 1 ;;
          [Nn]*) return 0 ;;
      esac
  done
}

determine_sourcedir()
{
    emacsver=`emacs --version | awk 'NR==1{print $3}'`
    if [[ -z "${emacsver}" ]]; then
      error "Emacs not installed on this system"
    fi
    debug "Found Emacs version ${emacsver}"
    if (( $(echo "${emacsver} > 26.3" |bc -l) )); then
        sourcedir="./emacs29"
    else
        sourcedir="./emacs26"
    fi
    debug "Using source directory ${sourcedir}"
    eval "$1='${sourcedir}'"
}

pkg_install()
{
    pkgArray=("emacs" "ripgrep")
    if ! type apt > /dev/null; then
      debug "Binary 'apt' not found, assuming rpm-based system"
      installed="$(rpm -qa)"
      pkgmgr="dnf"
    else
      pkgArray+=("libvterm-dev")
      debug "Found binary 'apt', assuming deb-based system"
      installed="$(dpkg-query -l)"
      pkgmgr="apt"
      pkgArray+=("spellcheck")
    fi

    for pkg in "${pkgArray[@]}"; do
      if grep -q "${pkg}" <<< "${installed}"; then
        debug "Found package ${pkg} on system"
      else
        debug "Package ${pkg} is not installed"
        sudo "${pkgmgr}" install "${pkg}"
      fi
    done
}

# ==================== ACTUAL FUNCTIONALITY ====================
install_doom()
{

    info "About to install Doom Emacs. "
    user_yesno "Do you want to install required packages (needs sudo)?"
    ans=$?
    if [[ "${ans}" -eq 1 ]]; then
        pkg_install
    fi

    if [[ -d "${emacsd}" ]]; then
        embkp="${emacsdbkp}_${datesuffix}"
        warn "Found existing ${emacsd}! Do you want to create a backup copy and continue?"
        user_input
        mv "${emacsd}" "${embkp}"
        debug "Renamed ${emacsd} to ${embkp}"
    fi
    if [[ -d "${doomd}" ]]; then
        dmbkp="${doomdbkp}_${datesuffix}"
        warn "Found existing ${doomd}! Do you want to create a backup copy and continue?"
        user_input
        mv "${doomd}" "${dmbkp}"
        debug "Renamed ${doomd} to ${dmbkp}"
    fi

    user_yesno "Do you want to perform a fresh Doom install from github.com/hlissner/?"
    ans=$?
    if [[ "${ans}" -eq 1 ]]; then
      info "Cloning doom-emacs repo from GitHub..."
      git clone https://github.com/hlissner/doom-emacs ~/.emacs.d
    else
      determine_sourcedir sourcedir
      info "Setting up ${emacsd} from this repo"
      cp -r "${sourcedir}/.emacs.d" "${emacsd}"
    fi
    info "Done"

    info "Setting up ${doomd}..."
    cp -r "${sourcedir}/.doom.d" "${doomd}"
    info "Done"

    info "Running doom installer..."
    debug "Ensure installer is executable"
    chmod +x "${emacsd}/bin/"*
    "${emacsd}/bin/doom" install
    info "Done"

    info "Remember to install Doom's fonts using"
    info "   M-x nerd-icons-install-fonts"
    info "ALL DONE"
    return 0
}

uninstall_doom()
{
    warn "This will PERMANENTLY remove your current ~/.emacs.d and ~/.doom.d configuration"
    user_input "Are you sure you want to do this?"

    info "Removing configuration directories..."
    rm -rf "${emacsd}"
    rm -rf "${doomd}"
    info "Done"

    user_yesno "Do you want to restore previously backed-up configuration directories?"
    ans=$?
    if [[ "${ans}" -eq 1 ]]; then
      debug "Looking for previously backed-up config directories"
      embkp=`ls -dt "${emacsdbkp}_"* 2>/dev/null`
      dmbkp=`ls -dt "${doomdbkp}_"* 2>/dev/null`

      if [[ -n "${embkp}" ]]; then
        info "Restoring ${embkp}"
        mv "${embkp}" "${emacsd}"
        info "Done"
      fi
      if [[ -n "${dmbkp}" ]]; then
        info "Restoring ${dmbkp}"
        mv "${embkp}" "${emacsd}"
        info "Done"
      fi
    fi

    info "ALL DONE"
    return 0
}

update_doom()
{
    determine_sourcedir sourcedir

    info "Updating config in ${doomd}..."
    cp "${sourcedir}/.doom.d/"* "${doomd}/"
    info "Done"

    user_yesno "Do you want to update doom itself from GitHub?"
    ans=$?
    if [[ "${ans}" -eq 1 ]]; then
      info "Updating doom-emacs repo from GitHub..."
      pushd "${emacsd}" > /dev/null
      git pull
      popd > /dev/null
      info "Done"
    fi

    info "Running doom sync"
    "${emacsd}/bin/doom" sync
    info "Done"

    info "ALL DONE"
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
datesuffix=$(date +"%Y%m%d_%H%M%S")
emacsd="${HOME}/.emacs.d"
emacsdbkp="${emacsd}_backup"
doomd="${HOME}/.doom.d"
doomdbkp="${doomd}_backup"

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
