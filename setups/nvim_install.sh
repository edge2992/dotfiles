#!/bin/bash -eu

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage --appimage-extract
sudo mv squashfs-root /
sudo ln -sf /squashfs-root/AppRun /usr/bin/nvim
rm nvim.appimage

