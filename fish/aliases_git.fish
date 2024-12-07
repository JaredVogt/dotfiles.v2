# Git Abbreviations for Fish Shell
# Save this as ~/.config/fish/conf.d/git_abbreviations.fish

# Helper functions
function git_main_branch
    set -l ref (git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null)
    if test $status -eq 0
        string replace -r '^refs/remotes/origin/' '' $ref
    else
        echo "main"
    end
end

function git_develop_branch
    echo "develop"
end

function git_current_branch
    git branch --show-current
end

# Basic git commands
abbr -a g 'git'
abbr -a ga 'git add'
abbr -a gaa 'git add --all'
abbr -a gapa 'git add --patch'
abbr -a gau 'git add --update'

# Branch commands
abbr -a gb 'git branch'
abbr -a gba 'git branch --all'
abbr -a gbd 'git branch --delete'
abbr -a gbD 'git branch --delete --force'
abbr -a gbm 'git branch --move'
abbr -a gbnm 'git branch --no-merged'
abbr -a gbr 'git branch --remote'

# Checkout commands
abbr -a gco 'git checkout'
abbr -a gcb 'git checkout -b'
abbr -a gcm 'git checkout (git_main_branch)'
abbr -a gcd 'git checkout (git_develop_branch)'

# Commit commands
abbr -a gc 'git commit --verbose'
abbr -a 'gc!' 'git commit --verbose --amend'
abbr -a gcn 'git commit --verbose --no-edit'
abbr -a 'gcn!' 'git commit --verbose --no-edit --amend'
abbr -a gca 'git commit --verbose --all'
abbr -a 'gca!' 'git commit --verbose --all --amend'
abbr -a gcam 'git commit --all --message'
abbr -a gcm 'git commit -m'
abbr -a gam 'git commit -am'          # Quick commit with inline message
abbr -a game 'git commit -a'          # Opens editor for commit message
abbr -a gcmsg 'git commit --message'
abbr -a gcs 'git commit --gpg-sign'

# Diff commands
abbr -a gd 'git diff'
abbr -a gdca 'git diff --cached'
abbr -a gds 'git diff --staged'
abbr -a gdw 'git diff --word-diff'

# Fetch commands
abbr -a gf 'git fetch'
abbr -a gfa 'git fetch --all --tags --prune --jobs=10'
abbr -a gfo 'git fetch origin'

# Log commands
abbr -a glg 'git log --stat'
abbr -a glgg 'git log --graph'
abbr -a glgga 'git log --graph --decorate --all'
abbr -a glo 'git log --oneline --decorate'
abbr -a glog 'git log --oneline --decorate --graph'
abbr -a gloga 'git log --oneline --decorate --graph --all'

# Merge commands
abbr -a gm 'git merge'
abbr -a gma 'git merge --abort'
abbr -a gmom 'git merge origin/(git_main_branch)'
abbr -a gmum 'git merge upstream/(git_main_branch)'

# Push & Pull commands
abbr -a gp 'git push'
abbr -a gpd 'git push --dry-run'
abbr -a gpf 'git push --force-with-lease --force-if-includes'
abbr -a gpr 'git pull --rebase'
abbr -a gpra 'git pull --rebase --autostash'
abbr -a gl 'git pull'

# Remote commands
abbr -a gr 'git remote'
abbr -a gra 'git remote add'
abbr -a grv 'git remote --verbose'
abbr -a grmv 'git remote rename'
abbr -a grrm 'git remote remove'
abbr -a grset 'git remote set-url'

# Reset commands
abbr -a grh 'git reset'
abbr -a grhh 'git reset --hard'
abbr -a grhs 'git reset --soft'

# Stash commands
abbr -a gsta 'git stash push'
abbr -a gstaa 'git stash apply'
abbr -a gstd 'git stash drop'
abbr -a gstl 'git stash list'
abbr -a gstp 'git stash pop'

# Status commands
abbr -a gst 'git status'
abbr -a gss 'git status --short'
abbr -a gsb 'git status --short --branch'

# Rebase commands
abbr -a grb 'git rebase'
abbr -a grba 'git rebase --abort'
abbr -a grbc 'git rebase --continue'
abbr -a grbi 'git rebase --interactive'
abbr -a grbm 'git rebase (git_main_branch)'

# Pretty log formats
abbr -a glol 'git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
abbr -a glola 'git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'

# Misc useful commands
abbr -a grt 'cd (git rev-parse --show-toplevel; or echo .)'
abbr -a gwip 'git add -A; and git rm (git ls-files --deleted) 2>/dev/null; and git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"'
