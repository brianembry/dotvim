
" borrowed heavily from https://github.com/bling/dotvim

" detect OS {{{
  let s:is_windows = has('win32') || has('win64')
  let s:is_cygwin = has('win32unix')
  let s:is_macvim = has('gui_macvim')
"}}}
"

" dotvim settings {{{
  let s:settings = {}
  let s:settings.default_indent = 2

  " override defaults with the ones specified in g:dotvim_settings
  for key in keys(s:settings)
    if has_key(g:dotvim_settings, key)
      let s:settings[key] = g:dotvim_settings[key]
    endif
  endfor

" }}}

" setup & neobundle {{{
  let s:cache_dir = '~/.vim/.cache'

  set nocompatible
  if s:is_windows
    set runtimepath+=~/.vim
  endif
  set runtimepath+=~/.vim/bundle/neobundle.vim/
  call neobundle#begin(expand('~/.vim/bundle/'))
  NeoBundleFetch 'Shougo/neobundle.vim'
" }}}


" functions {{{
  function! s:get_cache_dir(suffix) "{{{
    return resolve(expand(s:cache_dir . '/' . a:suffix))
  endfunction "}}}
  function! Source(begin, end) "{{{
    let lines = getline(a:begin, a:end)
    for line in lines
      execute line
    endfor
  endfunction "}}}
  function! Preserve(command) "{{{
    " preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " do the business:
    execute a:command
    " clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
  endfunction "}}}
  function! StripTrailingWhitespace() "{{{
    call Preserve("%s/\\s\\+$//e")
  endfunction "}}}
  function! EnsureExists(path) "{{{
    if !isdirectory(expand(a:path))
      call mkdir(expand(a:path))
    endif
  endfunction "}}}
"}}}



syn on
set nu
set history=1000
set wildmenu
set smartcase
set autoindent
set expandtab
set tabstop=2
set tabstop=2
set shiftwidth=2
set laststatus=2
set showmatch
set incsearch
set hlsearch

set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

" note: the final ';' is important. tells it to search upwards for semicolon
set tags=.tags;

" improve gui on mac
if s:is_macvim
  set antialias
  set guifont=Menlo:h14
endif

" vim file/folder management {{{
    " persistent undo
    if exists('+undofile')
      set undofile
      let &undodir = s:get_cache_dir('undo')
    endif

    " backups
    set backup
    let &backupdir = s:get_cache_dir('backup')

    " swap files
    let &directory = s:get_cache_dir('swap')
    set noswapfile

    call EnsureExists(s:cache_dir)
    call EnsureExists(&undodir)
    call EnsureExists(&backupdir)
    call EnsureExists(&directory)
  "}}}

  let mapleader = ","
  let g:mapleader = ","
"}}}


" plugins {{{

" fuzzy file/tag searching
NeoBundle 'kien/ctrlp.vim'

" left column buffer tags list
NeoBundle 'vim-scripts/taglist.vim'

" auto complete!

if has('lua')
  NeoBundleLazy 'Shougo/neocomplete.vim', {'autoload':{'insert':1}, 'vim_version':'7.3.885'} "{{{
    let g:neocomplete#enable_at_startup=1
    let g:neocomplete#data_directory=s:get_cache_dir('neocomplete')
  " }}}
endif

" allows switching between cpp/h files
NeoBundle 'derekwyatt/vim-fswitch'

" allows closing buffer w/o closing window!
NeoBundle 'rgarver/Kwbd.vim'

" color schemes
NeoBundle 'wesgibbs/vim-irblack'

" vcs plugins
NeoBundle 'matthauck/vimp4python'

" }}}

" plugin configuration {{{

" ctrlp

let g:ctrlp_match_window_reversed = 0
let g:ctrlp_root_markers = ['.agignore', '.gitignore']
let g:ctrlp_working_path_mode = 'ra'

let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup --hidden
      \ --ignore .git
      \ --ignore .svn
      \ --ignore .hg
      \ --ignore .DS_Store
      \ --ignore "**/*.pyc"
      \ -g ""'

" neo complete

" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3

" }}}


" key mappings {{{

" file fuzzy search
noremap <leader>t :CtrlP<CR>
" symbol fuzzy search
noremap <leader>r :CtrlPTag<cr>

" close buffer w/o closing window
map <leader>bd <Plug>Kwbd

" alt-o doesn't work right away on mac. set to nonsense mapping to not override real alt-o
" http://stackoverflow.com/questions/7501092/can-i-map-alt-key-in-vim
execute "set <M-0>=ø"
nnoremap <M-0> :FSHere<cr>
nnoremap <M-o> :FSHere<cr>

" re-map ctrl+t to jump to tag definition
map <c-t> <c-]><cr>

" opens sidebar of ctags for current buffer
map <leader>l :Tlist<CR>

" neocomplete

" tab completion
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" }}}


" finish loading {{{
  call neobundle#end()
  filetype plugin indent on
  syntax enable
  if has_key(s:settings, 'colorscheme')
    exec 'colorscheme '.s:settings.colorscheme
  endif 

  NeoBundleCheck
"}}}
