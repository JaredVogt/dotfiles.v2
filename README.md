# dotfiles.v2

### Install
* `git clone xx` this into `/projects/`
* `linkShellConfigFiles.sh` to create all the appropriate symlinks 

Here are the directories in `.config` to be documented.
```
fish
iterm2
karabiner
kitty
mdless
nvim
omf
tmux
zsh
```


TODO More explanation on the following is needed 
Hardlinks to
* `~/.local/share/fish/fish.history` # history file 
* `~/.local/share/z/data`  # directories that have been visited for easy access with `z` 

These are stored in a directory with the machine name. To access either of these files on a different machine, just copy them over. Having machines share them sounds complicated.

