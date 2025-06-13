function edit_dotfiles
    set original_dir (pwd)
    set target_dir $argv[1]
    set file
    
    cd $target_dir
    
    set file (git ls-files | fzf)
    if test -n "$file"
        nvim $file
    end
    
    cd $original_dir
end