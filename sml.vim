function! s:get_padding()
  let numberwidth = max([&numberwidth, strlen(line('$')) + 1])
  let numwidth = (&number || &relativenumber) ? numberwidth : 0
  let foldwidth = &foldcolumn

  if &signcolumn == 'yes'
    let signwidth = 2
  elseif &signcolumn =~ 'yes'
    let signwidth = &signcolumn
    let signwidth = split(signwidth, ':')[1]
    let signwidth *= 2
  elseif &signcolumn == 'auto'
    let supports_sign_groups = has('nvim-0.4.2') || has('patch-8.1.614')
    let signlist = execute(printf('sign place ' . (supports_sign_groups ? 'group=* ' : '') . 'buffer=%d', bufnr('')))
    let signlist = split(signlist, "\n")
    let signwidth = len(signlist) > 2 ? 2 : 0
  elseif &signcolumn =~ 'auto'
    let signwidth = 0
    if len(sign_getplaced(bufnr(),{'group':'*'})[0].signs)
      let signwidth = 0
      for l:sign in sign_getplaced(bufnr(),{'group':'*'})[0].signs
        let lnum = l:sign.lnum
        let signs = len(sign_getplaced(bufnr(),{'group':'*', 'lnum':lnum})[0].signs)
        let signwidth = (signs > signwidth ? signs : signwidth)
      endfor
    endif
    let signwidth *= 2
  else
    let signwidth = 0
  endif
  return numwidth + foldwidth + signwidth
endfunction

function! s:get_tabline_height()
  let is_show_tabline = &showtabline != 0
  let tab_page_count = tabpagenr('$')
  return tab_page_count > 1 && is_show_tabline == 1 ? 1 : 0
endfunction

function! s:focus_to_main_window()
   execute "0windo :"
endfunction

function! s:create_window()
  let line = getline('.')
  let row = winline() - 1 + s:get_tabline_height()
  let col = s:get_padding()
  let width = strdisplaywidth(line)
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
  let win_id = nvim_open_win(buf, v:true, config)
  call nvim_buf_set_option(buf, 'filetype', ft)
  call nvim_win_set_config(win_id, config)
  return win_id
endfunction

let g:select_line_mode = 0

function! s:mode_on() 
  let g:select_line_mode = 1
endfunction

function! s:select_line() abort
  let mode_on = get(g:, 'select_line_mode', 0)
  if mode_on == 1
    let line = getline('.')
    let win_id = s:create_window()
    call setline(line('.'), line)
    set cursorline
    call s:focus_to_main_window()
  endif
endfunction

command! Slm  call s:mode_on()
nnoremap <silent> <Space>v :call <SID>select_line()<CR>
