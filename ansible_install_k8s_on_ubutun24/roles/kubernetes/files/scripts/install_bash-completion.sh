#!/bin/bash

source /usr/share/bash-completion/bash_completion

if ! grep -q "source <(kubectl completion bash)" /root/.bashrc; then
    echo "source <(kubectl completion bash)" >> /root/.bashrc
fi

source /root/.bashrc
