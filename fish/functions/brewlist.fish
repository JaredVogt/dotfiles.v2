# create brew install of cli and cask downloads 
function brewlist
  set FILE_PATH '../../brew/'  # this puts files in ~/projects/dotfiles.v2/brew/
  # Get list to install
  set CORES (brew leaves)  # leaves gets top level casks
  set CASKS (brew list --casks)
  # Remove the old files
  rm $FILE_PATH'casks'
  rm $FILE_PATH'cores'
  # Write new cores
  for item in $CORES
    echo "$item" >> $FILE_PATH"cores" 
  end
  # Write new casks
  for item in $CASKS
    echo "$item" >> $FILE_PATH"casks" 
  end
end

# FIXME command below is available after first running brewlist. Hmm. Maybe I can combine all functions in a single file and prime it somehow
function quicktest
  set MY_TEST (mas)
  echo $MY_TEST
end
