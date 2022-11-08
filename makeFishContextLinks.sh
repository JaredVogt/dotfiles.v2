#!/usr/bin/env bash

# This is an attempt to create a fish directory per machine. See README.md
CONFIGDIR="$HOME/Dropbox/config/fish"
HOSTNAME=$(hostname)
HOSTNAMESUB=$(echo `expr "$HOSTNAME" : '\(.*\)\.'`)  # cleave off the .lan
# echo $HOSTNAMESUB

# check to see if directory exists - if it doesn't, than this is being run for the first time
# could ask user to select directory from which to import - which would copy the files into this new directory and then run the links at the bottom.

MACHINES=$(ls $CONFIGDIR)
echo $MACHINES
exit

# make the directory - just errors if it already exists
mkdir "$CONFIGDIR/$HOSTNAMESUB"

# link from share to Dropbox - just errors if it already exists
# ln ~/.local/share/fish/fish_history ~/Dropbox/config/fish/$HOSTNAMESUB/.
# ln ~/.local/share/z/data ~/Dropbox/config/fish/$HOSTNAMESUB/.

# move existing files to backup
mv -i ~/.local/share/fish/fish_history ~/.local/share/fish/fish_history.bak  
mv -i ~/.local/share/z/data ~/.local/share/z/data.bak 

# link from Dropbox to share - this would really just be for a restore process
ln ~/Dropbox/config/fish/$HOSTNAMESUB/fish_history $HOME/.local/share/fish/.
ln ~/Dropbox/config/fish/$HOSTNAMESUB/data $HOME/.local/share/z/.
