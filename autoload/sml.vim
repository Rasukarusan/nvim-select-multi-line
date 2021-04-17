let s:is_multi = 0
let g:select_line_mode = 0

" カレントバッファの行数分配列で初期化
" 行番号でバッファNoと文字列を管理する
function! s:init_winbufs() abort
  let s:winbufs = map(range(line('$')), 0)
  for line_no in range(0, line('$') - 1)
    let s:winbufs[line_no] = {'buf':0, 'str':''}
  endfor
endfunction

function! sml#mode_on()
  call s:init_winbufs()
  let g:select_line_mode = 1
  call s:set_keybind(1)
  echo 'Start select multi line!'
endfunction

function! s:mode_off()
  let g:select_line_mode = 0
  call s:set_keybind(0)
  call s:remove_windows()
endfunction

function! Filter(key, value)
    return a:value.buf !~ 0
endfunction

function! s:remove_windows() abort
  if len(s:winbufs) == 0
    return
  endif
  let filtered_winbufs = filter(s:winbufs, function("Filter"))
  for winbuf in filtered_winbufs
    execute winbuf.buf . 'bwipeout'
  endfor
endfunction

function! s:create_window()
  let line = getline('.')
  let line_no = line('.')
  let row = winline() - 1 + lib#window#get_tabline_height()
  let col = lib#window#get_padding()
  let width = line == '' ? 1 : strdisplaywidth(line)
  let ft = &filetype
  let config = {
    \'relative': 'editor',
    \ 'row': row,
    \ 'col': col,
    \ 'width': width,
    \ 'height': 1,
    \ 'anchor': 'NW',
    \ 'style': 'minimal',
    \}

  " toggle selection
  if s:winbufs[line_no].buf != 0
    execute s:winbufs[line_no].buf . 'bwipeout'
    let s:winbufs[line_no].buf = 0
    let s:winbufs[line_no].str = ''
    return
  endif

  let buf = nvim_create_buf(v:false, v:true)
  let win = nvim_open_win(buf, v:true, config)
  call nvim_buf_set_option(buf, 'filetype', ft)
  call nvim_win_set_option(win, 'winhighlight', 'Normal:Visual')
  call setline(line('.'), line)
  let s:winbufs[line_no] = {'buf': buf, 'str': line}
  return win
endfunction

function! s:set_keybind(mode) abort
  if a:mode == 1
    nnoremap <silent> v :call <SID>select_single()<CR>
    nnoremap <silent> V :call <SID>select_multi()<CR>
    nnoremap <silent> y :call <SID>yank()<CR>
    nnoremap <silent> j :call <SID>move_cursor(1)<CR>
    nnoremap <silent> k :call <SID>move_cursor(-1)<CR>
    nnoremap <silent> <C-c> :call <SID>mode_off()<CR>
  else
    nunmap v
    nunmap V
    nunmap y
    nunmap j
    nunmap k
    nunmap <C-c>
  endif
endfunction

function! s:move_cursor(direction) abort
  let is_multi = get(s:, 'is_multi', 0)
  if a:direction == 1
    call cursor(line('.') + 1, col('.'))
  else
    call cursor(line('.') - 1, col('.'))
  endif

  if is_multi == 1
    call s:create_window()
    call lib#window#focus_to_main_window()
  endif
endfunction

function! s:select_single() abort
  let mode = get(g:, 'select_line_mode', 0)
  if mode == 1
    call s:create_window()
    call lib#window#focus_to_main_window()
  endif
endfunction

function! s:select_multi() abort
  let is_multi = get(s:, 'is_multi', 0)
  if is_multi == 1
    let s:is_multi = 0
  else
    let s:is_multi = 1
    call s:create_window()
    call lib#window#focus_to_main_window()
  endif
endfunction

function! s:yank() abort
  let filtered_winbufs = filter(s:winbufs, function("Filter"))
  let yank_str = ''
  for winbuf in filtered_winbufs
    let yank_str .= winbuf.str . "\n"
  endfor
  echo '==========copyed!=========='
  echo yank_str
  echo '==========================='
  let @*=yank_str
  call s:mode_off()
endfunction
