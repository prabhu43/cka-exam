Minimal configuration in ~/.vimrc

Note: We have to add `source ~/.vimrc` in the `~/.bashrc` file

```
set ts=2
set sts=2
set sw=2
set expandtab // set et

set ruler
syntax on

set paste // during set paste: et,ts,retab will not work
set nu
```

While pasting something in yaml file, to avoid auto intendation `set paste`.
After pasted, `set nopaste`

`set line` to highlight the tabs and line-ends