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
env_to_clipboard()
{
    # Function used to put argument in clipboard
    EVAR=$1

    if [[ -z $EVAR ]];then
        echo "No variable passed as arg"
        exit 1
    fi

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
