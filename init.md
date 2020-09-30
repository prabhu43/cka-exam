echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "alias k=kubectl" >> ~/.bashrc
echo "complete -F __start_kubectl k" >> ~/.bashrc

echo "set -g prefix C-a" >> ~/.tmux.conf
echo "set -g mouse on" >> ~/.tmux.conf
echo "set -g history-limit 5000" >> ~/.tmux.conf
echo "bind _ split-window -h" >> ~/.tmux.conf
echo "bind - split-window -v" >> ~/.tmux.conf
echo "bind a send-prefix" >> ~/.tmux.conf

echo "set ts=2" >> ~/.vimrc
echo "set expandtab" >> ~/.vimrc
echo "set nu" >> ~/.vimrc

echo "alias kge=\"k get events -A --sort-by=.metadata.creationTimestamp\"" >> ~/.bashrc
