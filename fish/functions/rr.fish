# this reruns the last command and copies the stdin to the clipboard
function rr
  set PREV_CMD (history | head -1)
  set PREV_OUTPUT (eval $PREV_CMD)
  echo $PREV_OUTPUT | pbcopy  # maybe these last two could be combined.
end
