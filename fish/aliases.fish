#!/opt/homebrew/bin/fish

abbr -a l 'less'  # this uses actual less
abbr -a h 'history -R -n 75'
abbr -a hs 'history search'
abbr -a reload 'source ~/.config/fish/config.fish'
abbr -a r 'source ~/.config/fish/config.fish'
# abbr -a ralias 'nvim ~/.config/fish/setAbbreviations.sh'  # FIXME this is abandoned?
abbr -a raliases 'nvim ~/.config/fish/aliases.fish'
abbr -a aliases 'less ~/.config/fish/aliases.fish'
abbr -a lla 'exa --git -l -g --icons -h -a -H --time-style=long-iso'  # https://www.youtube.com/watch?v=KKxhf50FIPI&t=305s  
# git, long, group, icons, header, all , links, long-iso date / man exa   
abbr -a lll 'ls -alhF'
abbr -a less 'mdless'
abbr -a rmt 'trash'
abbr -a back 'cd -'
abbr -a rm 'trash'

# brew
abbr -a bs 'brew search'
abbr -a bi 'brew install'
abbr -a bic 'brew install --cask'

# application shortcuts
abbr -a imgcat '~/.iterm2/imgcat'
abbr -a ipm '/Applications/Inkdrop.app/Contents/Resources/app/ipm/bin/ipm'
abbr -a ks 'ksc -ms -p'
# abbr -a jv 'nvim -u ~/.config/nvim/jaredv.init.lua'
abbr -a sess 'nvim -S Session.vim'

# my shortcuts

# directories
abbr -a proj 'cd ~/projects && ls -alhF'
abbr -a config 'cd ~/.config && ls -alhF' # go to .config directory
abbr -a cellar 'cd /opt/homebrew/Cellar && ls -alhF'

# change themes
abbr -a theme-agno 'fisher install hauleth/agnoster'
abbr -a theme-tide 'fisher install IlanCosman/tide@v5'

# git abbreviations 
abbr -a g 'git'
abbr -a gam 'git commit -am'
abbr -a ga 'git add'
abbr -a gb 'git branch'
abbr -a gbl 'git blame'
abbr -a gc 'git commit -m'
abbr -a gcm 'git commit --amend -m'
abbr -a gca 'git commit -a'
abbr -a gco 'git checkout'
abbr -a gcp 'git cherry-pick'
abbr -a gd 'git diff'
abbr -a gf 'git fetch'
abbr -a gl 'git log'
abbr -a gm 'git merge'
abbr -a gp 'git push'
abbr -a gpf 'git push --force-with-lease'
abbr -a gpl 'git pull'
abbr -a gr 'git remote'
abbr -a grb 'git rebase'
abbr -a gs 'git status'
abbr -a gst 'git stash'
abbr -a gamm 'git commit --ammend'

# tmux abbreviations
abbr -a tl 'tmux list-sessions'
abbr -a ta 'tmux attach -t'
abbr -a tk 'tmux kill-session -t'
abbr -a tr 'tmux rename-session -t'
