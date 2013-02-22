
" If this .vimrc is not in $HOME, add these lines to $HOME/.vimrc :
"    set runtimepath+=/path/to/.vim
"    source /path/to/.vimrc
"==============================================================================

if exists('&guioptions')
    "no toolbar, no menu bar
    set guioptions-=T
    set guioptions-=m
    "don't source &runtimepath/menu.vim. (must be done before 'filetype on' / 'syntax on')
    set guioptions-=M
endif

let mapleader = ","
let g:mapleader = ","

let s:remember_session=1

"==============================================================================
" vundle   https://github.com/gmarik/vundle/
"==============================================================================
"     :BundleList          - list configured bundles
"     :BundleInstall(!)    - install(update) bundles
"     :BundleSearch(!) foo - search(or refresh cache first) for foo
"     :BundleClean(!)      - confirm(or auto-approve) removal of unused bundles

"boostrap vundle on new systems
fun! InstallVundle()
    echo "Installing Vundle..."
    silent !mkdir -p ~/.vim/bundle
    silent !git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
endfun

set nocompatible               " be iMproved
filetype off                   " required!

set runtimepath+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required! 
Bundle 'gmarik/vundle'

" repos on github
Bundle 'tpope/vim-sensible'
Bundle 'tpope/vim-fugitive'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'Lokaltog/vim-powerline'
Bundle 'kien/ctrlp.vim'
Bundle 'tpope/vim-surround'
Bundle 'justinmk/vim-syntax-extra'
Bundle 'PProvost/vim-ps1'
Bundle 'Shougo/neocomplcache'
Bundle 'tomtom/tcomment_vim'
Bundle 'ap/vim-css-color'

filetype plugin indent on     " required!

"exists() tests whether an option exists
"has() tests whether a feature was compiled in
fun! IsWindows()
    return has('win32') || has('win64')
endfun

fun! IsMac()
    return has('gui_macvim') || has('mac')
endfun

fun! IsUnix()
    return has('unix')
endfun

" 'is GUI' means vim is _not_ running within the terminal.
" sample values:
"   &term  = win32 //vimrc running in cygwin terminal
"   $TERM  = xterm-color , cygwin
"   &term  = builtin_gui //*after* vimrc but *before* gvimrc
"   &shell = C:\Windows\system32\cmd.exe , /bin/bash
fun! IsGui()
    return has('gui_running') || strlen(&term) == 0 || &term == 'builtin_gui'
endfun

" 'has GUI' means vim is "gui-capable"--but we may be using gvim/macvim from within the terminal.
fun! HasGui()
    return has('gui')
endfun

fun! EnsureDir(path)
    let l:path = expand(a:path)
    if (filewritable(l:path) != 2)
        if IsWindows()
            exe 'silent !mkdir "' . l:path . '"'
        else
            exe 'silent !mkdir -p "' . l:path . '"'
        endif
        redraw!
    endif
endfun

set hidden          " Allow buffer switching even if unsaved 
set mouse=a     	" Enable mouse usage (all modes)



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" general
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"set ttyfast
set lazyredraw  " no redraws in macros

set cmdheight=2 "The commandbar height

" Set backspace config
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

set ignorecase " case-insensitive searching
set smartcase  " but become case-sensitive if you type uppercase characters
set hlsearch   " highlight search matches

set magic " change the way backslashes are used in search patterns

set showmatch " When inserting paren, jump briefly to matching one.
set mat=5     " showmatch time (tenths of a second)

" No sound on errors
set noerrorbells
set novb t_vb=
set tm=1000


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nonumber
set background=dark
set showtabline=1

" platform-specific settings
if IsWindows()
    set gfn=Consolas:h10

    if IsWindows()
        " expects &runtimepath/colors/{name}.vim.
        colorscheme molokai
    endif
else
    if IsMac()
        " Use option (alt) as meta key.
        set macmeta

        if IsGui()
            " macvim options  :view $VIM/gvimrc
            let macvim_skip_colorscheme=1
            let macvim_skip_cmd_opt_movement=1

            " expects &runtimepath/colors/{name}.vim.
            colorscheme molokai
            
            "set guifont=Monaco:h16
            set guifont=Menlo:h14

            let g:Powerline_symbols = 'unicode'
        endif
    elseif IsGui() "linux or other
        set gfn=Monospace\ 10
    endif
endif

set fileformats=unix,dos,mac
set encoding=utf8
try
    lang en_US
catch
endtry


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" text, tab and indent 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set formatoptions+=rn1

set expandtab
set tabstop=4
set shiftwidth=4
set smarttab " Use 'shiftwidth' when using <Tab> in front of a line. By default it's used only for shift commands ("<", ">").

set linebreak "wrap long lines at 'breakat' character
set textwidth=500

set autoindent " Autoindent when starting new line, or using 'o' or 'O'.
set smartindent
set nowrap 
"set textwidth=80
set nofoldenable " disable folding

if exists('+syntax') 
    syntax enable "Enable syntax highlighting
endif
if exists('&colorcolumn')
    set colorcolumn=80 "highlight the specified column
endif

set cursorline     "highlight the current line

" =============================================================================
" util functions
" =============================================================================

" generate random number at end of current line 
" credit: http://mo.morsi.org/blog/node/299
" usage:
"   :Rand <CR>
"   :Rand 100<CR>
function! s:Rand(max)
y a         
redir @b    
ruby << EOF
  rmax = VIM::evaluate("a:max")
  rmax = nil if rmax == ""
  printf rand(rmax).to_s
EOF
redir END 
    let @a = strpart(@a, 0, strlen(@a) - 1)
    let @b = strpart(@b, 1, strlen(@b) - 1)
    let @c = @a . @b
    .s/.*/\=@c/g
endfunction
command! -nargs=? Rand :call <SID>Rand(<q-args>)

function! BreakBefore(s)
    execute ':%s/' . a:s . '/\r' . a:s . '/g'
endfunction
function! BreakAfter(s)
    execute ':%s/' . a:s . '/' . a:s . '\r/g'
    " :%s/}/\r}\r/g
    " :%s/;/;\r/g
endfunction

" =============================================================================
" visual mode 
" =============================================================================
" in visual mode, press * or # to search for the current selection
vnoremap * :call VisualSearch('f')<CR>
vnoremap # :call VisualSearch('b')<CR>

" vimgrep 
map <leader>g :vimgrep // ./*.<left><left><left><left><left><left>

" From an idea by Michael Naumann
function! VisualSearch(direction) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'b'
        execute "normal ?" . l:pattern . "^M"
    elseif a:direction == 'gv'
        call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.')
    elseif a:direction == 'f'
        execute "normal /" . l:pattern . "^M"
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction


" =============================================================================
" command/ex mode
" =============================================================================
" Emacs-style movement (like Bash)
:cnoremap <M-b>  <S-Left>
:cnoremap <M-f>  <S-Right>

" =============================================================================
" normal mode
" =============================================================================
" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Toggle paste mode
map <leader>pp :setlocal paste! paste?<cr>

" paste current dir to command line
cno $c e <C-\>eCurrentFileDir("e")<cr>

" $q is super useful when browsing on the command line
cno $q <C-\>eDeleteTillSlash()<cr>


func! DeleteTillSlash()
  let g:cmd = getcmdline()
  if IsWindows()
    let g:cmd_edited = substitute(g:cmd, "\\(.*\[\\\\]\\).*", "\\1", "")
  else
    let g:cmd_edited = substitute(g:cmd, "\\(.*\[/\]\\).*", "\\1", "")
  endif
  if g:cmd == g:cmd_edited
    if IsWindows()
      let g:cmd_edited = substitute(g:cmd, "\\(.*\[\\\\\]\\).*\[\\\\\]", "\\1", "")
    else
      let g:cmd_edited = substitute(g:cmd, "\\(.*\[/\]\\).*/", "\\1", "")
    endif
  endif   
  return g:cmd_edited
endfunc

func! CurrentFileDir(cmd)
  return a:cmd . " " . expand("%:p:h") . "/"
endfunc


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" moving around, tabs and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Close the current buffer
map <leader>bd :Bclose<cr>

" ctrl+arrow to switch buffers
map <c-right> :bn<cr>
map <c-left> :bp<cr>

" avoid annoying insert-mode ctrl+u behavior
imap <C-u> <Esc><C-u>

" switch to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>


command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
   let l:currentBufNum = bufnr("%")
   let l:alternateBufNum = bufnr("#")

   if buflisted(l:alternateBufNum)
     buffer #
   else
     bnext
   endif

   if bufnr("%") == l:currentBufNum
     new
   endif

   if buflisted(l:currentBufNum)
     execute("bdelete! ".l:currentBufNum)
   endif
endfunction


""""""""""""""""""""""""""""""
" statusline
""""""""""""""""""""""""""""""
let g:Powerline_stl_path_style = 'short'


"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction

iab xdate <c-r>=strftime("%d/%m/%y %H:%M:%S")<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" key mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Remap VIM 0
map 0 ^

" 'un-join' (split) the current line at the cursor position
nnoremap K i<cr><esc>k$

inoremap jj <ESC>
nnoremap <space> :
nmap <leader>w :w!<cr>

"toggle/untoggle spell checking
map <leader>ss :setlocal spell!<cr>

"text bubbling: move text up/down with meta-[jk] 
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z
vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

"Delete trailing white space, useful for Python ;)
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite *.py :call DeleteTrailingWS()

set guitablabel=%t

" replay @q macro for each line of a visual selection
vnoremap @q :normal @q<CR>
" repeat last command for each line of a visual selection
vnoremap . :normal .<CR>


nnoremap <leader>a :Ack

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" cope
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Do :help cope if you are unsure what cope is. It's super useful!
map <leader>cc :botright cope<cr>
map <leader>n :cn<cr>
map <leader>p :cp<cr>




""""""""""""""""""""""""""""""
" python
""""""""""""""""""""""""""""""
let python_highlight_all = 1
au FileType python syn keyword pythonDecorator True None False self

au BufNewFile,BufRead *.jinja set syntax=htmljinja
au BufNewFile,BufRead *.mako set ft=mako

au FileType python inoremap <buffer> $r return 
au FileType python inoremap <buffer> $i import 
au FileType python inoremap <buffer> $p print 
au FileType python inoremap <buffer> $f #--- PH ----------------------------------------------<esc>FP2xi
au FileType python map <buffer> <leader>1 /class 
au FileType python map <buffer> <leader>2 /def 
au FileType python map <buffer> <leader>C ?class 
au FileType python map <buffer> <leader>D ?def 


""""""""""""""""""""""""""""""
" javascript
"""""""""""""""""""""""""""""""
au FileType javascript setl nocindent
au FileType javascript imap <c-a> alert();<esc>hi
au FileType javascript inoremap <buffer> <leader>r return 
au FileType javascript inoremap <buffer> $f //--- PH ----------------------------------------------<esc>FP2xi


""""""""""""""""""""""""""""""
" vim grep
""""""""""""""""""""""""""""""
let Grep_Skip_Dirs = 'RCS CVS SCCS .svn generated'
set grepprg=/bin/grep\ -nH


" =============================================================================
" omni complete
" =============================================================================
autocmd FileType css set omnifunc=csscomplete#CompleteCSS

" Don't scan included files. Tags file is more performant.
set complete-=i

let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_smart_case = 1
"disable neocomplcache for matching buffer names
"let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

" =============================================================================
" ctrlp
" =============================================================================
set wildignore+=*.o,*.obj,*.class,.git,*.pyc,*/tmp/*,*.so,*.swp,*.zip,*.exe

if IsWindows()
    set wildignore+=.git\\*,.hg\\*,.svn\\*,Windows\\*,Program\ Files\\*,Program\ Files\ \(x86\)\\* 
else
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/* 
endif

let g:ctrlp_cmd = 'CtrlPMixed' 
let g:ctrlp_extensions = ['tag', 'buffertag']
if IsWindows()
    let g:ctrlp_buftag_ctags_bin = '~/bin/ctags.exe'
endif

" CtrlP auto-generates exuberant ctags for the current buffer!
nnoremap <c-t> :CtrlPBufTagAll<cr>
" CtrlP buffer switching (this makes minibufexpl pretty much obsolete)
nnoremap <c-b> :CtrlPBuffer<cr>

let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn|cache)$|AppData|eclipse_workspace',
  \ 'file': '\v\~$|\.(exe|so|dll|pdf|ntuser|blf|dat|regtrans-ms|o|swp|pyc|wav|mp3|ogg|blend)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }


" =============================================================================
" session  http://vim.wikia.com/wiki/Go_away_and_come_back
" =============================================================================

" do *not* save global variables/mappings/options
set sessionoptions-=options
set sessionoptions-=globals

function! GetSessionDir()
    "expand ~ to absolute path so that mkdir works on windows
    "                     . substitute(getcwd(), 'C:', '/c', 'g')
    return expand("~/.vim/sessions")
endfunction

let s:sessionfile = expand(GetSessionDir() . "/session.vim")
let s:sessionlock = expand(GetSessionDir() . "/session.lock")

function! SaveSession()
  "disable session save/load for CLI
  if !HasGui() || !IsGui()
    return
  endif

  if (filereadable(s:sessionfile))
    let b:sessionfile_bk = s:sessionfile . '.' . strftime("%Y-%m-%d") . '.bk'
    echo b:sessionfile_bk
    if IsWindows()
        exe 'silent !copy ' . s:sessionfile . ' ' . b:sessionfile_bk
        exe 'silent !del ' . s:sessionlock 
    else
        exe 'silent !cp ' . s:sessionfile . ' ' . b:sessionfile_bk
        exe 'silent !rm -f ' . s:sessionlock 
    endif
  endif

  EnsureDir(GetSessionDir())

  exe "mksession! " . s:sessionfile
endfunction

function! LoadSession()
  "disable session save/load for CLI
  if !HasGui() || !IsGui()
    return
  endif

  if (filereadable(s:sessionlock))
    echo "Session already open in another vim."
  elseif (filereadable(s:sessionfile))
    "write the session 'lock' file
    exe "new | w " . s:sessionlock . " | bd"
    
    "open the session
    exe 'source ' s:sessionfile

    "set up trigger to save on exit
    autocmd VimLeave * :call SaveSession()
  else
    echo "No session loaded."
  endif
endfunction


" Auto Commands
if has("autocmd")
    " Jump to the last position when reopening a file
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

    if IsGui()
        if !exists("s:remember_session") || s:remember_session != 0
            set viminfo+=% "remember buffer list
            autocmd VimEnter * nested :call LoadSession()
        endif
    endif
endif

" always maximize GUI window size
if IsWindows()
    au GUIEnter * simalt ~x 
endif

" enforce black bg, etc.
highlight Normal ctermbg=black guibg=black 
highlight Normal ctermfg=white guifg=white 

"j,k move by screen line instead of file line
nnoremap j gj
nnoremap k gk

" disable F1 help key
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

" disable Ex mode shortcut
nmap Q <nop>

" turn off search highlighting
nmap <silent> <leader>hs :noh<cr>

"ensure transient dirs (for sensible.vim)
let s:dir = (has('win32') || has('win64')) ? $APPDATA . '/Vim' : has('mac') ? '~/Library/Vim' : '~/.local/share/vim'
call EnsureDir(s:dir . '/swap/')
call EnsureDir(s:dir . '/backup/')
call EnsureDir(s:dir . '/undo/')


