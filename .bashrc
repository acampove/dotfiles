#!/usr/bin/env bash

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
