" カレントバッファの行数分配列で初期化
" 行番号でバッファNoと文字列を管理する
function! s:init_winbufs() abort
  let s:winbufs = map(range(line('$') + 1), 0)
  for line_no in range(0, line('$'))
    let s:winbufs[line_no] = {'buf':0, 'str':''}
  endfor
endfunction

function! sml#mode_on()
  echo 'Start select multi line!'
  call s:init_winbufs()
  call s:enable_keybind()
endfunction

function! s:mode_off()
  call s:disable_keybind()
  call s:remove_windows()
endfunction

function! s:remove_windows() abort
  if len(s:winbufs) == 0 | return | endif
  let filtered_winbufs = filter(s:winbufs, { index, val -> val.buf != 0 })
  for winbuf in filtered_winbufs
    execute winbuf.buf . 'bwipeout'
  endfor
endfunction

function! s:select_line()
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
  call lib#window#focus_to_main_window()
  return win
endfunction

function! s:enable_keybind() abort
  nnoremap <silent> v :call <SID>select_line()<CR>
  nnoremap <silent> V :call <SID>toggle_visual_mode_linewise()<CR>
  nnoremap <silent> y :call <SID>yank()<CR>
  nnoremap <silent> d :call <SID>delete()<CR>
  nnoremap <silent> <C-c> :call <SID>mode_off()<CR>
endfunction

function! s:disable_keybind() abort
  nunmap v
  nunmap V
  nunmap y
  nunmap d
  nunmap <C-c>
  if get(s:, 'is_visual_mode_linewise', 0) == 1
    let s:is_visual_mode_linewise = 0
    nunmap j
    nunmap k
  endif
endfunction

function! s:move_cursor(direction) abort
  call cursor(line('.') + a:direction, col('.'))
  call s:select_line()
endfunction

function! s:toggle_visual_mode_linewise() abort
  let is_visual_mode_linewise = get(s:, 'is_visual_mode_linewise', 0)
  let s:is_visual_mode_linewise = is_visual_mode_linewise ? 0 : 1
  if is_visual_mode_linewise == 0
    nnoremap <silent> j :call <SID>move_cursor(1)<CR>
    nnoremap <silent> k :call <SID>move_cursor(-1)<CR>
    call s:select_line()
  else
    nunmap j
    nunmap k
  endif
endfunction

function! s:yank() abort
  let filtered_winbufs = filter(s:winbufs, { index, val -> val.buf != 0 })
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

function! s:get_line_no(index, val) abort
  if a:val.buf != 0 
    return a:index
  endif
endfunction
function! s:delete() abort
  let lines = map(deepcopy(s:winbufs), {index, val -> s:get_line_no(index, val)})
  let target_lines = filter(lines, { index, val -> val > 0})
  for target_line in reverse(target_lines)
    execute target_line . ',' . target_line .'d'
  endfor
  call s:mode_off()
endfunction
