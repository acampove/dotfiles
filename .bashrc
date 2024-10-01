#!/usr/bin/env bash

#------------------------------------------------------------------
setLbEnv()
{
    SCRIPT=/cvmfs/lhcb.cern.ch/lib/LbEnv

    if [ -f $SCRIPT ]; then
        . $SCRIPT
    fi
}
#------------------------------------------------------------------
to_clipboard()
{
    # Function used to put argument in clipboard
    DATA=$1

    if [[ -z $DATA ]];then
        echo "No variable passed as arg"
        exit 1
    fi

    which xclip > /dev/null
    if [[ $? -ne 0 ]];then
        echo "xclip not found"
        exit 1
    fi

    echo $DATA | xclip -selection clipboard

    echo "Copied \"$DATA\" to clipboard"
}
#------------------------------------------------------------------
set_alias()
{
    echo "Setting common aliases"
    #------------------------------------------------------------------
    #Tmux
    #------------------------------------------------------------------
    alias tmuxn="tmux new -s"
    alias tmuxa="tmux attach -t"
    alias tmuxl="tmux list-sessions | column -t"
}
#------------------------------------------------------------------
set_fzf()
{
    which fzf > /dev/null

    if [[ $? -ne 0 ]];then
        return
    fi

    eval "$(fzf --bash)"
}
#------------------------------------------------------------------
set_alias

if   [[ "$(hostname)" == "ubuntu"*  ]];then
    echo "Running .bashrc for laptop"
    source ~/.bashrc_laptop
    source ~/.bashrc_laptop_ext
elif [[ "$(hostname)" == "lxlogin"* ]];then
    echo "Running .bashrc for IHEP"
    source ~/.bashrc_ihep
elif [[ "$(hostname)" == "lxplus"* ]];then
    echo "Running .bashrc for LXPLUS"
    source ~/.bashrc_lxplus
else
    echo "Unrecognized host $(hostname), not using .bashrc file"
fi
