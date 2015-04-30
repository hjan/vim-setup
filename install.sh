#!/bin/bash
# TODO: Remove several redundant checks (we could be a bit more clever about checking for updates...)

ARG=$1
# Set the directory the script is stored in to make the script callable from anywhere
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Defines for better outputs
bold=`tput bold`
normal=`tput sgr0`

# This will basically just check whether an update is available or not
function has_update()
{
    # Bring remote refs up-to-date before we do anything
    git remote update > /dev/null 2>&1

    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse @{u})
    BASE=$(git merge-base HEAD @{u})
    
    if [ $LOCAL = $REMOTE ]; then
        return 1
    elif [ $LOCAL = $BASE ]; then
        return 0
    fi
}

# Check if any plugins can be updated and return the amount
# TODO: This should use the 'plugin' file rather than ls -A (see update_plugins)
function check_plugins()
{
    AMOUNT=0
    cd ${DIR}/.vim/bundle
    for plugin in `ls -A`; do
        cd $plugin
        if has_update; then
            ((AMOUNT++))
        fi
        cd - > /dev/null 2>&1
    done
    cd $DIR
    echo $AMOUNT
}

# This will do actual updates - pulling from git etc.
# TODO: meh
function update()
{
    git pull
}

# This will set up everything necessarry to make vim use all of our
# configurations stored in the repo. It also pulls all plugins we're
# running at the moment.
function install()
{
    echo "${bold}Setting up Symlinks...${normal}"
    ln -sf -t ~/ ${DIR}/.vim
    ln -sf ${DIR}/.vimrc ~/.vimrc
    
    echo "${bold}Creating tmp, backup and undo directories...${normal}"
    mkdir -p ${DIR}/.vim/tmp
    mkdir -p ${DIR}/.vim/backup
    mkdir -p ${DIR}/.vim/undo
    
    # Install all plugins found in 'plugins'
    echo "${bold}Installing plugins...${normal}"

    REPOS=$(cat plugins)
    # Make sure we've got the bundle directory
    mkdir -p ${DIR}/.vim/bundle
    cd ${DIR}/.vim/bundle/
    INSTALLED_PLUGINS=$(ls -A)
    for repo in $REPOS; do
        # Let's check if we've got the plugin installed already 
        # (even though it shouldn't be the case since we're doing a fresh install - so..yea)
        found=0
        for plugin in $INSTALLED_PLUGINS; do
            if [[ $repo =~ /${plugin}.git ]]; then
               found=1 
               break
            fi
        done
        if [ $found = 1 ]; then
            continue
        fi

        # Clone the repo of the plugin if it isn't installed yet
        git clone $repo
    done
    cd - > /dev/null 2>&1
    touch .installed
    echo "${bold}Done.${normal}"
}

# This will update all installed plugins.
# We're also going to check 'plugins' for new entries to install new plugins.
function update_plugins()
{
    REPOS=$(cat plugins)
    cd ${DIR}/.vim/bundle/
    for repo in $REPOS; do
        PLUGIN=$(echo $repo | sed -e 's/.*\///' | sed -e 's/\.git//')
        if [ -e $PLUGIN ] && [ -d $PLUGIN ]; then
            # Let's see if we can update the plugin
            cd $PLUGIN
            if [ -e .git ]; then
                echo "${bold}Check plugin:${normal} ${PLUGIN}"
                if ! has_update; then
                    echo "${PLUGIN} ${bold}is up-to-date.${normal}"
                else
                    echo "${bold}Updating${normal} ${PLUGIN}..."
                    git pull
                fi
                cd - > /dev/null 2>&1
            else
                # So, if we've got the plugin directory but no .git directory inside of it
                # let's just remove everything there and re-install it
                echo "${bold}Re-Installing${normal} ${PLUGIN}..."
                cd - > /dev/null 2>&1
                rm -rf ${PLUGIN}
                git clone $repo
            fi
        else
            # If there is no directory, we obviously haven't installed that plugin yet
            # so let's do it now
            echo "${bold}Installing new plugin:${normal} ${PLUGIN}"
            git clone $repo
        fi
    done
    cd $DIR
}

function usage()
{
cat <<EOF
This script helps to manage and maintain the vim configuration
Usage: ./manage.sh <option> 
Options:
    install         - Do the initial installation
    check           - Check whether updates are available
    update          - Update everything (includes update-plugins)
    update-plugins  - Updates all plugins and installs new ones found in the 'plugins' file
    help            - Show this help
EOF
}

case "$ARG" in
    install)
        if [ ! -e ${DIR}/.installed ]; then
            install
        else
            echo "vim-setup allready installed. Check for updates with './manage.sh check'"
        fi
    ;;
    update)
        echo "${bold}Checking for updates...${normal}"
        upd_for_plugins=$(check_plugins)
        if ! has_update && [ "$upd_for_plugins" = "0" ]; then
            echo "Your setup is up-to-date."
        else
            echo "${bold}Updates available - Updating...${normal}"
            update
            update_plugins
        fi
    ;;
    update-plugins)
        update_plugins
    ;;
    check)
        echo "${bold}Checking for updates...${normal}"
        upd_for_plugins=$(check_plugins)
        if ! has_update && [ "$upd_for_plugins" = "0" ]; then
            echo "Your setup is up-to-date."
        else
            echo "There are updates available. Use './manage.sh update' to start the updating process."
        fi
    ;;
    *|help)
        usage
    ;;
esac

exit $?
