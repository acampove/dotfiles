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
    #------------------------------------------------------------------
    #VIM
    #------------------------------------------------------------------
    alias vim="nvim"
}
#------------------------------------------------------------------
lxplus()
{
    MACHINE=$1
    ssh -4 -D 8080 acampove@lxplus$MACHINE.cern.ch
}
#-----------------------------------------------------
ihep()
{
    if [[ -z $1 ]];then
        ssh -X campoverde@lxlogin.ihep.ac.cn
    elif [[ $1 =~ "^7[0-9]{2}$:" ]];then
        ssh -X campoverde@lxslc$1.ihep.ac.cn
    else
        ssh -X campoverde@lxlogin$1.ihep.ac.cn
    fi
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

if   [[ "$(hostname)" == "almalinux"*  ]];then
    echo "Running .bashrc for almalinux"
    source ~/.bashrc_almalinux
elif [[ "$(hostname)" == "ubuntu"*  ]];then
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
