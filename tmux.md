Mostly tmux might be installed in Ubuntu. If not

```sh
apt-get update && apt-get install tmux
```

Create a very minimal configuration file in the home path (~/.tmux.conf)

```bash
set -g prefix C-a  # tmux prefix control-a
set -g mouse on    # scrollable
set -g history-limit 50000 # scroll history

bind - split-window -v # split vertical using -
bind _ split-window -h # split horizontal using _

bind C-a send-prefix # Ctrl-a + Ctrl-a to go to begining of line
```

##### Minimal Shortcuts:

- create new session
    - `prefix + :new` and then `prefix + s` to switch to new session
    - `tmux new -s name -d` and then `prefix + s` to switch to new session
- create window `prefix + c   `
- zoom in/out panes `prefix + z   `
- switch sessions `prefix + s   `
- rename session `prefix + $   `
