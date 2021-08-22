Nvim Select Multi Lines
====

Yank lines not adjacent

<img width="500" src="https://user-images.githubusercontent.com/17779386/115108415-52a98f00-9fab-11eb-9543-a1e37717a764.gif" />


Or delete

<img width="500" src="https://user-images.githubusercontent.com/17779386/115111961-116eaa80-9fbe-11eb-85e7-0470571b246d.gif" />


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

## Getting Started

1. `:call sml#mode_on()` to enter select mode.
2. Press <kbd>v</kbd> to select line.
3. Press <kbd>y</kbd> to yank. (or <kbd>d</kbd> to delete)

| keybind | description |
| ------ | ------ |
| v | select a line  |
| V | toggle visual mode linewise |
| y | yank selected lines |
| d | delete selected lines |
| j | move cursor down  |
| k | move cursor up |
| Ctrl-c | exit select mode |

## Settings

Add a mapping in your `init.vim`.

```vim
" any leader key
nnoremap <Space>v :call sml#mode_on()<CR>
```

You can control whether or not to output after yank by `g:sml#echo_yank_str`. Default 1.

```vim
let g:sml#echo_yank_str = 0
```
