#!/usr/bin/env bash

#------------------------------------------------------------------
track_memory()
{
    if [[ -z $THIS_VENV ]];then
        echo "Could not find THIS_VENV in the environment"
        echo "This function has to be called from within a conda/mamba environment"
        return 1
    fi

    mma $THIS_VENV 

    which psrecord > /dev/null 2>&1
    if [[ $? -ne 0 ]];then
        echo "Cannot find psrecord, not tracking memory" 
        return 1
    fi

    $@ &

    # Get the PID of the last background process
    PID=$!

    psrecord "$PID" --interval 1 --plot memory.png
}
#------------------------------------------------------------------
protect_tree()
{
    DIR_PATH=$1
    if [[ ! -d $DIR_PATH ]];then
        echo "Cannot project \"$DIR_PATH\", not found"
        return
    fi

    echo "Protecting: \"$DIR_PATH\""

    sudo chattr -R +i $DIR_PATH 
}
#------------------------------------------------------------------
unprotect_tree()
{
    DIR_PATH=$1
    if [[ ! -d $DIR_PATH ]];then
        echo "Cannot unproject \"$DIR_PATH\", not found"
        return
    fi

    echo "Unprotecting: \"$DIR_PATH\""

    sudo chattr -R -i $DIR_PATH 
}
#------------------------------------------------------------------
gng()
{
    # Start ganga, setup first the LHCb environment if not setup
    which ganga > /dev/null 2>&1

    if [[ $? -ne 0 ]];then
        echo "Setting up LHCb environment"
        . /cvmfs/lhcb.cern.ch/lib/LbEnv
    else
        echo "Not setting up LHCb environment"
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
    export VENVS=$HOME/VENVS
    export EDITOR=nvim
    export VISUAL=nvim
    export PYTHONWARNINGS=ignore
    export BAKDIR=/run/media/acampove/backup/$(hostname)

    # This should allow use of Run1/2 code that needs input
    # Ntuples.
    #
    # For Run3 this was replaced with ANADIR and it should
    # vary from machine to machine
    export DATDIR=/publicfs/ucas/user/campoverde/Data/RK
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

    alias mmd='$MAMBA deactivate'
    alias mmi='$MAMBA install'
    alias mml='$MAMBA env list'
    alias mmr='$MAMBA env remove -n'
}
#-----------------------------------------------------
# Remove packages
mmu()
{
    PACKAGE=$1

    if [[ -z $PACKAGE ]];then
        echo "First argument, package is missing"
    fi

    $MAMBA remove $PACKAGE
}
#-----------------------------------------------------
# Create environment
mmc()
{
    if [ "$#" -lt 1 ]; then
        echo "Error: At least one argument is required." >&2
        return 1
    fi

    NAME=$1
    shift
    PACKAGES=("$@")

    set_mamba_name

    $MAMBA create -n $NAME $PACKAGES pysocks
}
# Attach environment
#-----------------------------------------------------
mma()
{
    VENV=$1

    $MAMBA activate $VENV

    export THIS_VENV=$VENV

    set_fzf
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
        source ~/.bashrc_local
        source ~/.bashrc_$(hostname)
    elif [[ "$(hostname)" == "thinkpad-t430"     ]];then
        echo "Running .bashrc for $(hostname)"
        source ~/.bashrc_local
        source ~/.bashrc_$(hostname)
    elif [[ "$(hostname)" == "thinkbook"         ]];then
        echo "Running .bashrc for $(hostname)"
        source ~/.bashrc_local
        source ~/.bashrc_$(hostname)
    elif [[ "$(hostname)" == "ubuntu"*  ]];then
        echo "Running .bashrc for laptop"
        source ~/.bashrc_local
        source ~/.bashrc_thinkbook
    # --------------------------------------------------------------
    elif [[ "$(hostname)" == "lbbuildhack"*  ]];then
        echo "Running .bashrc for HLT machines"
        source ~/.bashrc_lxplus
    elif [[ "$(hostname)" == *".ihep.ac.cn" ]];then
        echo "Running .bashrc for IHEP"
        source ~/.bashrc_ihep
    elif [[ "$(hostname)" == *".cern.ch"    ]];then
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
