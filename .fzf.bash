# Setup fzf
# ---------
if [[ ! "$PATH" == */home/acampove/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/acampove/.fzf/bin"
fi

eval "$(fzf --bash)"
