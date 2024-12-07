# dotfiles.v2

### Install
* `git clone xx` this into `/projects/`
* `linkShellConfigFiles.sh` to create all the appropriate symlinks 

Here are the directories in `.config` to be documented.
```
atuin
brew
fish
git
iterm2
karabiner
mdless
nushell
omf
starship
tmux
vimium
wezterm
yazi
zsh
```


TODO More explanation on the following is needed 
Hardlinks to
* `~/.local/share/fish/fish.history` # history file (why??)
* `~/Library/Application Support/zoxide/db.zo`  # these are the zoxide directories that have been visited. The file is a binary. FIXME.. can this be moved 

These are stored in a directory with the machine name. To access either of these files on a different machine, just copy them over. Having machines share them sounds complicated.

