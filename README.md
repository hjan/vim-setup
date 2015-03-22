# vim setup tool
This bash script allows easy vim configuration for all workstations you'd use vim on and
helps keeping them up-to-date, so that you always work with the same vim environment.

You can easily install your familiar vim configuration on new machines or after reinstalling
your OS.

## Installation
Just clone or download this repository and run `./install.sh`. You may adjust the permission bit
for execution beforehand: `chmod u+x install.sh`

Wherever you put this script, everything vim related will be stored within that directory.
During the installation, the script will create sub-directories for temp-, backup- and undo-files.
It will then create symlinks for `~/.vim/` and `~/.vimrc` to point to the installation directory.

## Plugins
Plugins are usually installed through plugin managers for vim. As of now, the script only checks for
plugin-updates by checking what plugins are installed in the `~/.vim/bundle` directory and uses the
`plugin`-file to figure out the sources.


## Usage
`./install.sh [<option>]`

### Options
* `check` - Check whether updates are available
* `update`- Update everything (includes update-plugins)
* `update-plugins` - Updates all plugins and installs new ones found in the 'plugins' file
* `help` - Display the usage

# TODO / Suggestions
If you've got ideas for improvements or any kind of suggestions, feel free to file issues for that.

I'm already thinking about re-writing the script in python to support other platforms beside GNU/Linux as well.
Also, there are tools for installing plugins easily already. That should be integrated somehow.
