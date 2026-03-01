#!/usr/bin/env bash

# nvimの設定が無ければsymlinkを貼る
if [ -e "$HOME/.config/nvim" ]; then
    echo "~/.config/nvim already exists"
else
    ln -s "$(pwd)" "$HOME/.config/nvim"
fi

# Lazyでプラグインを事前にインストール
nvim --headless "+Lazy! sync" +qa
