- create a new tmux session for each task. If task is done, rename the session name to `task${no}-done`. It will be easy to come back to unfinished task and proceed from where it was left previously.
```
tmux new -s task1

## Rename session
ctrl+a, $ 
```