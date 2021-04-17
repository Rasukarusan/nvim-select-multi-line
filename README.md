Nvim Select Multi Line
====

yank specific line
![demo.gif](https://user-images.githubusercontent.com/17779386/115108415-52a98f00-9fab-11eb-9543-a1e37717a764.gif)

or delete
![demo2.gif](https://user-images.githubusercontent.com/17779386/115111961-116eaa80-9fbe-11eb-85e7-0470571b246d.gif)

## Description

Neovim plugin.  
You can select multiple lines that are not adjacent.

## Requirement

- Neovim >= 0.4

## Install

You can use the plugin manager. e.g. dein.vim
```vim
[[plugins]]
repo = 'Rasukarusan/nvim-select-multi-line'
```

Manually
```vim
cd $XDG_CONFIG_HOME/nvim/plugin
git clone https://github.com/Rasukarusan/nvim-select-multi-line.git
```

## Usage

Add a mapping in your `init.vim`.

```vim
" any leader key
nnoremap <Space>v :call sml#mode_on()<CR>
```

## Settings

You can control whether or not to output after yank by `g:sml#echo_yank_str`. Default 1.

init.vim
```vim
let g:sml#echo_yank_str = 0
```
