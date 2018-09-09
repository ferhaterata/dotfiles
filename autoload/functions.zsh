# Use gpip to install global python packages, as pip requires virtualenv
gpip() {
    PIP_REQUIRE_VIRTUALENV="" pip "$@"
}

# Use neovim as manpager in zsh
local NMAN="$XDG_CONFIG_HOME/nvim/plugged/neoman.vim/scripts/nman.zsh"
if [[ -a $NMAN ]]
then
    source $NMAN
fi

# This will find the most frequently issued command issued exactly in this directory,
# or if there are no matches it will find the most frequently issued command in any directory.
_zsh_autosuggest_strategy_histdb_top() {
    local query="select commands.argv from
history left join commands on history.command_id = commands.rowid
left join places on history.place_id = places.rowid
where commands.argv LIKE '$(sql_escape $1)%'
group by commands.argv
order by places.dir != '$(sql_escape $PWD)', count(*) desc limit 1"
    suggestion=$(_histdb_query "$query")
}
# ZSH_AUTOSUGGEST_STRATEGY=histdb_top

# Precmd hook in order to get correct timing information for 'zsh-histdb'
autoload -Uz add-zsh-hook
add-zsh-hook precmd histdb-update-outcome

function zshexit() {
    # Sync the history database on every exit
    histdb-sync

    # Deactivate venv on exit
    [ "$VIRTUAL_ENV" ] && deactivate
}

function fixsystemdboot() {
    # Mount the EFI partition
    mkdir -p /Volumes/EFI
    mount /dev/disk0s1 /Volumes/EFI

    # "Bless" the systemd boot loader
    sudo bless --mount /Volumes/EFI --setBoot --file /Volumes/EFI/EFI/systemd/systemd-bootx64.efi --shortform
}

function setup_gpg_keys() {
    # A function to setup GPG keys on a new system
    local PRIVATE_KEY=/tmp/private.key

    xdg-open "https://keybase.io/jakobgm"
    vared -p "Have you copied your private PGP key to your system clipboard[Y/n]: " -c REPLY

    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        return 1
    fi
    xclip -o -sel clip > $PRIVATE_KEY

    printf "--- Importing secret key ---\n"
    gpg --allow-secret-key-import --import $PRIVATE_KEY

    printf "\n--- Importing public key from keybase ---\n"
    curl -Ls https://keybase.io/jakobgm/pgp_keys.asc | gpg --import

    rm $PRIVATE_KEY
}


# Change git repo to use SSH instead
function github_ssh() {
    git remote set-url origin git@github.com:$1/$2.git
}

# Run sphinx docserver on internal ip adress
function internal_ds() {
    INTERNAL_IP=$(ip addr show | rg -o "inet (.+)/.+global.+" -r '$1')
    firefox $INTERNAL_IP:8000
    sphinx-autobuild . _build --host $INTERNAL_IP
}
