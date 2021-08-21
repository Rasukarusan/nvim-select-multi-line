let s:mark_ns = nvim_create_namespace('sml')
let s:mark_ids = []
let s:selected_lines = []

function! s:init_selected_lines() abort
  let s:selected_lines = []
endfunction

function! sml#mode_on()
  echo 'Start select multi line!'
  call s:init_selected_lines()
  call s:enable_keybind()
endfunction

function! s:mode_off()
  call s:disable_keybind()
  call s:remove_marks()
endfunction

function! s:remove_marks() abort
  for mark_id in s:mark_ids
    call nvim_buf_del_extmark(0, s:mark_ns, mark_id)
  endfor
endfunction

function! s:select_line()
  let line = getline('.')
  let line_no = line('.')
  let width = line == '' ? 1 : strdisplaywidth(line)

  let mark_id = nvim_buf_set_extmark(0, s:mark_ns, line_no - 1, 0, {
        \ "end_line" : line_no - 1,
        \ "end_col" : width,
        \ "hl_group" : "Visual",
        \})
  call add(s:mark_ids, mark_id)
  call add(s:selected_lines, {'line_no': line_no, 'str': line})
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

function! s:cursor_move(direction) abort
  let pre_direction = get(s:, 'pre_direction', 0)
  if pre_direction != 0 && pre_direction != a:direction
    call s:select_line()
    call cursor(line('.') + a:direction, col('.'))
  else
    call cursor(line('.') + a:direction, col('.'))
    call s:select_line()
    let s:pre_direction = a:direction
  endif

endfunction

function! s:toggle_visual_mode_linewise() abort
  let is_visual_mode_linewise = get(s:, 'is_visual_mode_linewise', 0)
  let s:is_visual_mode_linewise = is_visual_mode_linewise ? 0 : 1
  if is_visual_mode_linewise == 0
    let s:pre_direction = 0
    nnoremap <silent> j :call <SID>cursor_move(1)<CR>
    nnoremap <silent> k :call <SID>cursor_move(-1)<CR>
    call s:select_line()
  else
    nunmap j
    nunmap k
  endif
endfunction

function! s:yank() abort
  let yank_str = ''
  for selected in s:selected_lines
    let yank_str .= selected.str . "\n"
  endfor
  call s:echo_yank_str(yank_str)
  let @*=yank_str
  call s:mode_off()
endfunction

function! s:echo_yank_str(yank_str) abort
  if get(g:, 'sml#echo_yank_str', 1) == 1
    echo '==========yanked!=========='
    echo a:yank_str
    echo '==========================='
  else
    echo 'yanked!'
  endif
endfunction

function! s:delete() abort
  for selected in s:selected_lines
    execute selected.line_no . ',' . selected.line_no .'d'
  endfor
  call s:mode_off()
endfunction
