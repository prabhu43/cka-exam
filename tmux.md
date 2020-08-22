Mostly tmux might be installed in Ubuntu. If not

```sh
apt-get update && apt-get install tmux
```

Create a very minimal configuration file in the home path (~/.tmux.conf)

```bash
set -g prefix C-a  # tmux prefix control-a
set -g mouse on    # scrollable
set -g history-limit 50000

bind - split-window -v # split vertical using -
bind _ split-window -h # split horizontal using _
```

##### Minimal Shortcuts:

- create new session `prefix + :new`
- create window `prefix + c   `
- zoom in/out panes `prefix + z   `
- switch sessions `prefix + s   `
- rename session `prefix + $   `
