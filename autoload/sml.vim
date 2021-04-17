let s:winbufs = []
let g:select_line_mode = 0

function! s:mode_on()
  let g:select_line_mode = 1
  call s:set_keybind(1)
endfunction

function! s:mode_off()
  let g:select_line_mode = 0
  call s:set_keybind(0)
  call s:remove_windows()
endfunction

function! s:remove_windows() abort
  if len(s:winbufs) == 0
    return
  endif
  for winbuf in s:winbufs
    execute winbuf . 'bwipeout'
  endfor
  let s:winbufs = []
endfunction

function! s:create_window()
  let line = getline('.')
  let row = winline() - 1 + lib#window#get_tabline_height()
  let col = lib#window#get_padding()
  let width = line == '' ? 1 : strdisplaywidth(line)
  let config = {
    \'relative': 'editor',
    \ 'row': row,
    \ 'col': col,
    \ 'width': width,
    \ 'height': 1,
    \ 'anchor': 'NW',
    \ 'style': 'minimal',
    \}
  let ft = &filetype

  let buf = nvim_create_buf(v:false, v:true)
  let win = nvim_open_win(buf, v:true, config)
  call add(s:winbufs, buf)
  call nvim_buf_set_option(buf, 'filetype', ft)
  call nvim_win_set_option(win, 'winhighlight', 'Normal:Visual')
  " call nvim_win_set_config(win, config)
  return win
endfunction

function! s:set_keybind(mode) abort
  if a:mode == 1
    nnoremap <silent> v :call sml#select_single()<CR>
    nnoremap <silent> V :call sml#select_multi()<CR>
    nnoremap <silent> <C-c> :call <SID>mode_off()<CR>
  else
    nunmap v
    nunmap V
    nunmap <C-c>
  endif
endfunction

function! sml#select_single() abort
  let mode = get(g:, 'select_line_mode', 0)
  if mode == 1
    let line = getline('.')
    let win_id = s:create_window()
    call setline(line('.'), line)
    call lib#window#focus_to_main_window()
  endif
endfunction


function! sml#select_multi() abort
  echo 'multi'
endfunction

nnoremap T :call <sid>mode_on()<CR>
