- create a new tmux session for each task. If task is done, rename the session name to `task${no}-done`. It will be easy to come back to unfinished task and proceed from where it was left previously.
```
tmux new -s task1

## Rename session
ctrl+a, $ 
```

- To create some pods for debugging
```
k run busybox --image busybox -- sleep 1d
k run utils --image arunvelsriram/utils -- sleep 1d
```