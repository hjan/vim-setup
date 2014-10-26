#!/bin/bash


ARG=$1
# Set the directory the script is stored in to make the script callable from anywhere
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Defines for better outputs
bold=`tput bold`
normal=`tput sgr0`

# This will basically just check whether an update is available or not
function check()
{
    # Bring remote refs up-to-date before we do anything
    git remote update > /dev/null 2>&1

    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u})
    BASE=$(git merge-base @ @{u})
    
    if [ $LOCAL = $REMOTE ]; then
        return 1
    elif [ $LOCAL = $BASE ]; then
        return 0
    fi
}

# Check if any plugins can be updated and return the amount
function check_plugins()
{
    AMOUNT=0
    cd ${DIR}/.vim/bundle
    for plugin in `ls -A`; do
        cd $plugin
        if ! check; then
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
    git pull https://github.com/hjan/vim-setup.git
}

# This will set up everything necessarry to make vim use all of our
# configurations stored in the repo. It also pulls all plugins we're
# running at the moment.
function install()
{
    echo "${bold}Setting up Symlinks...${normal}"
    ln -sf -t ~/ ${DIR}/.vim
    ln -sf ${DIR}/.vimrc ~/.vimrc
    
    echo "${bold}Creating temp and backup directories...${normal}"
    mkdir -p ${DIR}/.vim/tmp
    mkdir -p ${DIR}/.vim/backup
    
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
    echo "${bold}Done."
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
                if [ check ]; then
                    echo "${PLUGIN} ${bold}is up-to-date."
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
Usage: ./install.sh [<option>] - Installs and sets up everything necessarry to make vim use the repo configuration
Options:
    check           - Check whether updates are available
    update          - Update everything (includes update-plugins)
    update-plugins  - Updates all plugins and installs new ones found in the 'plugins' file
    help            - Show this help
EOF
}

case "$ARG" in
    update)
        upd_for_plugins=$(check_plugins)
        if check && [ "$upd_for_plugins" = "0" ]; then
            echo "Your setup is up-to-date."
        else
            echo "${bold}Updating...${normal}"
            update
            update_plugins
        fi
    ;;
    update-plugins)
        update_plugins
    ;;
    check)
        upd_for_plugins=$(check_plugins)
        if check && [ "$upd_for_plugins" = "0" ]; then
            echo "Your setup is up-to-date."
        else
            echo "There are updates available. Use './install.sh update' to update."
        fi
    ;;
    help)
        usage
    ;;
    *) 
        if [ ! -e ${DIR}/.installed ]; then
            install
        else
            echo "vim-setup allready installed. Check for updates with './install.sh check'"
        fi
    ;;
esac

exit $?
