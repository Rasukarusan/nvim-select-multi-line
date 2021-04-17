if exists("g:loaded_select_multi_line")
  finish
endif
let g:loaded_select_multi_line = 1

nnoremap <Space>v :call sml#mode_on()<CR>
