#/usr/bin/bash 

python3 -m venv ~/.local --system-site-packages
~/.local/bin/pip3 install --user --upgrade pynvim

pnpm install -g neovim
