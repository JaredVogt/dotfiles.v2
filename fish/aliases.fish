#!/opt/homebrew/bin/fish

abbr -a l 'less'  # this uses actual less
abbr -a h 'history -R -n 75'
abbr -a hs 'history search'
abbr -a reload 'source ~/.config/fish/config.fish'
abbr -a ralias '~/.config/fish/setAbbreviations.sh'
abbr -a aliases 'less ~/.config/fish/setAbbreviations.sh'
abbr -a lla 'exa --git -l -g --icons -h -a -H --time-style=long-iso'  # https://www.youtube.com/watch?v=KKxhf50FIPI&t=305s  
# git, long, group, icons, header, all , links, long-iso date / man exa   
abbr -a lll 'ls -alhF'
abbr -a less 'mdless'
abbr -a rmt 'trash'
abbr -a back 'cd -'

# brew
abbr -a bs 'brew search'
abbr -a bi 'brew install'
abbr -a bic 'brew install --cask'

# application shortcuts
abbr -a imgcat '~/.iterm2/imgcat'
abbr -a ipm '/Applications/Inkdrop.app/Contents/Resources/app/ipm/bin/ipm'
abbr -a lvim '/Users/jaredvogt/.local/bin/lvim'
abbr -a luv 'nvim -u ~/.config/nvim/init.lua'

# directories
abbr -a proj 'cd ~/projects && ls -alhF'
abbr -a config 'cd ~/.config && ls -alhF' # go to .config directory
abbr -a cellar 'cd /opt/homebrew/Cellar && ls -alhF'

# change themes
abbr -a theme-agno 'fisher install hauleth/agnoster'
abbr -a theme-tide 'fisher install IlanCosman/tide@v5'
# Some git related abbrs
# abbr -a gits git status
abbr -a g 'git'
abbr -a gam 'git commit -am'
abbr -a ga 'git add'
abbr -a gb 'git branch'
abbr -a gbl 'git blame'
abbr -a gc 'git commit -m'
abbr -a gca 'git commit --amend -m'
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
