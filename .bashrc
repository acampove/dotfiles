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

    if [[ -f $DATA ]];then
        cat  $DATA | xclip -selection clipboard
    else
        echo $DATA | xclip -selection clipboard
    fi

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
    #------------------------------------------------------------------
    #Mamba
    #------------------------------------------------------------------
    set_mamba_name

    alias mmc='$MAMBA create -n'
    alias mmd='$MAMBA deactivate'
    alias mmi='$MAMBA install'
    alias mml='$MAMBA env list'
    alias mmr='$MAMBA env remove -n'
}
#-----------------------------------------------------
set_mamba_name()
{
    which mamba > /dev/null 2>&1
    if [[ $? -eq 0 ]];then
        export MAMBA=mamba
        echo "Using $MAMBA"
        return
    fi

    which micromamba > /dev/null 2>&1
    if [[ $? -eq 0 ]];then
        export MAMBA=micromamba
        echo "Using $MAMBA"
        return
    fi

    echo "Neither mamba nor micromamba found"
}
#-----------------------------------------------------
mma()
{
    VENV=$1

    $MAMBA activate $VENV

    set_fzf
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
    which fzf > /dev/null 2>&1

    if [[ $? -ne 0 ]];then
	echo "fzf not found, not initializing it"
        return
    fi

    echo "Initialing environment with fzf"

    eval "$(fzf --bash)"
}
#------------------------------------------------------------------
customize()
{
    # Prevent tab from escaping the $ to \$
    shopt -s direxpand

    #screen freezes with CRL-s, this fixes it:
    #https://unix.stackexchange.com/questions/12107/how-to-unfreeze-after-accidentally-pressing-ctrl-s-in-a-terminal

    #Remove inappropiate ioctl...
    #https://stackoverflow.com/a/25391867/5483727
    [[ $- == *i* ]] && stty -ixon
}
#------------------------------------------------------------------
call_machine_bash()
{
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
}
#------------------------------------------------------------------
set_alias
customize
call_machine_bash
