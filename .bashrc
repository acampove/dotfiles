#!/usr/bin/env bash

if   [[ "$(hostname)" == "ubuntu"*  ]];then
    source ~/.bashrc_laptop
    source ~/.bashrc_laptop_ext
elif [[ "$(hostname)" == "lxlogin"* ]];then
    source ~/.bashrc_ihep
else
    echo "Unrecognized host $(hostname), not using .bashrc file"
fi
