#!/bin/bash

pipx install visidata

if [ ! -e /workspaces/pict.nvim ]; then
    ln -sf /workspaces/pict-nvim /workspaces/pict.nvim
fi
