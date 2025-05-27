# dotfiles.v2

### Install
4. `sshSetup.sh` this setups up keys for github (follow instructions)
1. `git clone xx` this into `/projects/`
2. `linkShellConfigFiles.sh` to create all the appropriate symlinks 
3. `linkCloudStorageProviders.sh` to create all the appropriate symlinks (dropbox/gdrive have to be installed first)

Here are the directories in `.config` to be documented.
```
atuin
brew
fish
ghostty
git
helix
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


TODO More explanation on the following is needed (cruft until explained)
Hardlinks to
* `~/.local/share/fish/fish.history` # history file (why??)
* `~/Library/Application Support/zoxide/db.zo`  # these are the zoxide directories that have been visited. The file is a binary. FIXME.. can this be moved 

These are stored in a directory with the machine name. To access either of these files on a different machine, just copy them over. Having machines share them sounds complicated.

