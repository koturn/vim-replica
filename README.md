vim-replica
===========

Easy REPL in Vim.

## Usage

Launch repl.

```vim
:Replica [command-name]
```

You can also use `if_xxx` in replica buffer as following.

```vim
:ReplicaInternal [if_xxx-name]
```

## Installation

### With [dein.vim](https://github.com/Shougo/neobundle.vim)

Write following code to your `.vimrc` and execute `:call dein#install()` in
your Vim.

```vim
call dein#add('koturn/vim-replica', {
      \ 'on_cmd': [
      \   'Replica',
      \   'ReplicaInternal'
      \ ]
      \})
```

### With [NeoBundle](https://github.com/Shougo/neobundle.vim)

Write following code to your `.vimrc` and execute `:NeoBundleInstall` in your
Vim.

```vim
NeoBundle 'koturn/vim-replica'
```

If you want to use `:NeoBundleLazy`, write following code in your .vimrc.

```vim
NeoBundle 'koturn/vim-replica', {
      \ 'on_cmd': [
      \   'Replica',
      \   'ReplicaInternal'
      \ ]
      \}
```

### With [Vundle](https://github.com/VundleVim/Vundle.vim)

Write following code to your `.vimrc` and execute `:PluginInstall` in your Vim.

```vim
Plugin 'koturn/vim-replica'
```

### With [vim-plug](https://github.com/junegunn/vim-plug)

Write following code to your `.vimrc` and execute `:PlugInstall` in your Vim.

```vim
Plug 'koturn/vim-replica'
```

### With [vim-pathogen](https://github.com/tpope/vim-pathogen)

Clone this repository to the package directory of pathogen.

```
$ git clone https://github.com/koturn/vim-replica.git ~/.vim/bundle/vim-replica
```

### With packages feature

In the first, clone this repository to the package directory.

```
$ git clone https://github.com/koturn/vim-replica.git ~/.vim/pack/koturn/opt/vim-replica
```

Second, add following code to your `.vimrc`.

```vim
packadd vim-replica
```

### With manual

If you don't want to use plugin manager, put files and directories on
`~/.vim/`, or `%HOME%/vimfiles/` on Windows.


## Requirements

Vim 8 job.


## LICENSE

This software is released under the MIT License, see [LICENSE](LICENSE).
