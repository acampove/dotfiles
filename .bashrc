#!/usr/bin/env bash

#------------------------------------------------------------------
set_env()
{
    export EDITOR=vim
    export VISUAL=vim
}
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
    MACHNE=$1
    ssh -4 -X campoverde@lxlogin$MACHNE.ihep.ac.cn
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
set_java()
{
    which java > /dev/null 2>&1

    if [[ $? -ne 0 ]];then
        echo "Java not found"
        return
    fi

    export JAVA_HOME=$(readlink -f $(which java) | sed 's|/bin/java||g')
    echo "JAVA run time found, JAVA_HOME=$JAVA_HOME"
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
        source ~/.bashrc_local
    elif [[ "$(hostname)" == "thinkpad"*   ]];then
        echo "Running .bashrc for almalinux"
        source ~/.bashrc_almalinux
        source ~/.bashrc_local
    elif [[ "$(hostname)" == "ubuntu"*  ]];then
        echo "Running .bashrc for laptop"
        source ~/.bashrc_laptop
        source ~/.bashrc_local
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
set_env
set_java
set_alias
customize
call_machine_bash
