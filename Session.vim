let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/projects/dotfiles.v2
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +12 linkShellConfigFiles.sh
badd +1784 kitty/kitty.conf
badd +30 fish/aliases.fish
badd +38 fish/config.fish
badd +1 starship/starship.toml
badd +1 atuin/config.toml
argglobal
%argdel
$argadd linkShellConfigFiles.sh
$argadd kitty/kitty.conf
$argadd fish/aliases.fish
set stal=2
tabnew +setlocal\ bufhidden=wipe
tabnew +setlocal\ bufhidden=wipe
tabnew +setlocal\ bufhidden=wipe
tabnew +setlocal\ bufhidden=wipe
tabnew +setlocal\ bufhidden=wipe
tabrewind
edit linkShellConfigFiles.sh
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 2 - ((1 * winheight(0) + 57) / 114)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 2
normal! 0
tabnext
edit kitty/kitty.conf
argglobal
2argu
balt linkShellConfigFiles.sh
setlocal fdm=marker
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
3
normal! zo
241
normal! zo
431
normal! zo
587
normal! zo
779
normal! zo
856
normal! zo
1053
normal! zo
1411
normal! zo
1798
normal! zo
1922
normal! zo
2460
normal! zo
let s:l = 1784 - ((57 * winheight(0) + 57) / 114)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 1784
normal! 0
tabnext
edit fish/config.fish
argglobal
1argu
if bufexists(fnamemodify("fish/config.fish", ":p")) | buffer fish/config.fish | else | edit fish/config.fish | endif
if &buftype ==# 'terminal'
  silent file fish/config.fish
endif
balt kitty/kitty.conf
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 38 - ((37 * winheight(0) + 57) / 114)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 38
normal! 02|
tabnext
edit starship/starship.toml
argglobal
if bufexists(fnamemodify("starship/starship.toml", ":p")) | buffer starship/starship.toml | else | edit starship/starship.toml | endif
if &buftype ==# 'terminal'
  silent file starship/starship.toml
endif
balt fish/config.fish
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 28 - ((27 * winheight(0) + 57) / 114)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 28
normal! 06|
tabnext
edit atuin/config.toml
argglobal
if bufexists(fnamemodify("atuin/config.toml", ":p")) | buffer atuin/config.toml | else | edit atuin/config.toml | endif
if &buftype ==# 'terminal'
  silent file atuin/config.toml
endif
balt starship/starship.toml
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 1 - ((0 * winheight(0) + 57) / 114)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 1
normal! 0
tabnext
edit fish/aliases.fish
argglobal
3argu
balt linkShellConfigFiles.sh
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 30 - ((29 * winheight(0) + 57) / 114)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 30
normal! 023|
tabnext 3
set stal=1
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
set hlsearch
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
