function nf
    set original_dir (pwd)
    set file
    
    cd ~/projects/dotfiles.v2
    
    set file (fzf)
    if test -n "$file"
        nvim $file
    end
    
    cd $original_dir
end