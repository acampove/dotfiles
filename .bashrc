#!/usr/bin/env bash

#------------------------------------------------------------------
gng()
{
    # Start ganga, setup first the LHCb environment if not setup
    which ganga > /dev/null 2>&1

    if [[ $? -ne 0 ]];then
        . cvmfs/lhcb.cern.ch/lib/LbEnv
    fi

    ganga --quiet --no-mon
}
#------------------------------------------------------------------
lb_dirac()
{
    # Will create a shell with dirac and some basic environment specified by .bashrc_dirac
    
    which lb-dirac > /dev/null 2>&1

    if [[ $? -ne 0 ]];then
        echo "Cannot find lb-dirac, LHCb software not set, setting it"
        setLbEnv
    fi

    if [[ ! -f $HOME/.bashrc_dirac ]];then
        echo "Cannnot find ~/.bashrc_dirac"
        exit 1
    fi

    lb-dirac bash -c "source ~/.bashrc_dirac && exec bash --norc"
}
#------------------------------------------------------------------
setLbEnv()
{
    # This function will setup the LHCb environment

    LBENV_PATH=/cvmfs/lhcb.cern.ch/lib/LbEnv

    if [[ ! -f $LBENV_PATH ]]; then
        echo "Cannot find $LBENV_PATH"
        kill INT $$
    fi

    . $LBENV_PATH
}
#------------------------------------------------------------------
set_global_env()
{
    export EDITOR=nvim
    export VENVS=$HOME/VENVS
    export VISUAL=nvim
    export PYTHONWARNINGS=ignore
    export BAKDIR=/run/media/acampove/backup/$(hostname)
}
#------------------------------------------------------------------
backup()
{
    EXCLUDE=$HOME/.config/restic/excluded_files
    if [[ ! -f $EXCLUDE ]];then
        echo "No exclude files found: $EXCLUDE"
        return
    fi

    which restic > /dev/null 2>&1
    if [[ $? -ne 0 ]];then
        echo "restic not found"
        return
    fi

    if [[ ! -d $BAKDIR ]];then
        echo "Backup directory not found: $BAKDIR"
        return
    fi

    restic -r $BAKDIR backup $HOME --exclude-file $EXCLUDE
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

    which xclip > /dev/null 2>&1

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
set_global_alias()
{
    echo "Setting common aliases"
    #------------------------------------------------------------------
    #Utilities
    #------------------------------------------------------------------
    alias rbash='source ~/.bashrc'
    #------------------------------------------------------------------
    #Python
    #------------------------------------------------------------------
    alias python='python3'
    alias ipython='ipython3'
    #------------------------------------------------------------------
    #Tmux
    #------------------------------------------------------------------
    alias tmuxn="tmux new -s"
    alias tmuxa="tmux attach -t"
    alias tmuxd="tmux detach-client"
    alias tmuxc="tmux new-window"
    alias tmuxl="tmux list-sessions | column -t"
    #------------------------------------------------------------------
    #VIM
    #------------------------------------------------------------------
    alias vim='nvim'
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
    echo "Running commands to fix default behavior of system"
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
    if   [[ "$(hostname)" == "thinkpad-x1carbon" ]];then
        echo "Running .bashrc for $(hostname)"
        source ~/.bashrc_$(hostname)
        source ~/.bashrc_local
    elif [[ "$(hostname)" == "thinkpad-t430"     ]];then
        echo "Running .bashrc for $(hostname)"
        source ~/.bashrc_$(hostname)
        source ~/.bashrc_local
    elif [[ "$(hostname)" == "ubuntu"*  ]];then
        echo "Running .bashrc for laptop"
        source ~/.bashrc_thinkbook
        source ~/.bashrc_local
    # --------------------------------------------------------------
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
call_machine_bash
set_global_env
set_global_alias
set_java
customize
