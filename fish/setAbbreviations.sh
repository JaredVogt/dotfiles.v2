#!/opt/homebrew/bin/fish
# ~/.config/fish/setAbbreviations.sh

abbr -a -U l 'less'
abbr -a -U h 'history -R -n 75'
abbr -a -U hs 'history search'
abbr -a -U imgcat '~/.iterm2/imgcat'
abbr -a -U config 'cd ~/.config && ls -alhF' # go to config file
abbr -a -U reload 'source ~/.config/fish/config.fish'
abbr -a -U ralias '~/.config/fish/setAbbreviations.sh'
abbr -a -U alias 'less ~/.config/fish/setAbbreviations.sh'
abbr -a -U proj 'cd ~/projects && ls -alhF'
abbr -a -U lla 'exa --git -l -g --icons -h -a -H --time-style=long-iso'  # https://www.youtube.com/watch?v=KKxhf50FIPI&t=305s  
# git, long, group, icons, header, all , links, long-iso date / man exa   
abbr -a -U lll 'ls -alhF'
abbr -a -U ipm '/Applications/Inkdrop.app/Contents/Resources/app/ipm/bin/ipm'
abbr -a -U cellar 'cd /opt/homebrew/Cellar && ls -alhF'
abbr -a -U less 'mdless'
abbr -a -U rmt 'trash'
abbr -a -U back 'cd -'

# Some git related abbrs
abbr -a -U g 'git'
abbr -a -U ga 'git add'
abbr -a -U gb 'git branch'
abbr -a -U gbl 'git blame'
abbr -a -U gc 'git commit -m'
abbr -a -U gca 'git commit --amend -m'
abbr -a -U gco 'git checkout'
abbr -a -U gcp 'git cherry-pick'
abbr -a -U gd 'git diff'
abbr -a -U gf 'git fetch'
abbr -a -U gl 'git log'
abbr -a -U gm 'git merge'
abbr -a -U gp 'git push'
abbr -a -U gpf 'git push --force-with-lease'
abbr -a -U gpl 'git pull'
abbr -a -U gr 'git remote'
abbr -a -U grb 'git rebase'
abbr -a -U gs 'git status'
abbr -a -U gst 'git stash'
