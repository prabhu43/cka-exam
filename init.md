# aliases
echo "alias k=kubectl" >> ~/.bashrc
echo "alias kns=\"kubectl config set-context --current --namespace\"" >> ~/.bashrc
echo "alias kge=\"kubectl get events -A --sort-by=.metadata.creationTimestamp\"" >> ~/.bashrc

# auto completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "complete -F __start_kubectl k" >> ~/.bashrc

# vim
echo "set ts=2" >> ~/.vimrc
echo "set sts=2" >> ~/.vimrc
echo "set sw=2" >> ~/.vimrc
echo "set expandtab" >> ~/.vimrc
echo "set ruler" >> ~/.vimrc
echo "syntax on" >> ~/.vimrc
echo "filetype indent plugin on" >> ~/.vimrc
echo "set nu" >> ~/.vimrc
echo "source ~/.vimrc" >> ~/.bashrc # we have to source at end

# tmux
echo "set -g prefix C-a" >> ~/.tmux.conf
echo "set -g mouse on" >> ~/.tmux.conf
echo "set -g history-limit 5000" >> ~/.tmux.conf
echo "bind _ split-window -h" >> ~/.tmux.conf
echo "bind - split-window -v" >> ~/.tmux.conf
echo "bind a send-prefix" >> ~/.tmux.conf

source ~/.bashrc

# tmux solve
# copy easily and paste in tmux
# search in tmux