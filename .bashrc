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
set_alias()
{
    echo "Setting common aliases"
    #------------------------------------------------------------------
    #Tmux
    #------------------------------------------------------------------
    alias tmuxn="tmux new -s"
    alias tmuxa="tmux attach -t"
    alias tmuxl="tmux list-sessions"
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
else
    echo "Unrecognized host $(hostname), not using .bashrc file"
fi
