#!/bin/bash

source alias/common_alias

USER_HOME=$(eval echo ~${SUDO_USER})

check_dependencies() {
  sudo apt update
  DEPEND_FAIL=
  echo "Dependencies:"
  for i in "$@"; do
    { type "$i" > /dev/null 2>&1 && echo "$i PASS"; } ||
    { echo "$i FAIL"; DEPEND_FAIL="$DEPEND_FAIL $i"; }
  done

  if [ -n "$DEPEND_FAIL" ]; then
    echo "Do you want to install all missing dependencies? [Y/n]"
    read -r want_install
    if echo "$want_install" | grep -iq "^n"; then
      exit 1
    else
      for i in $DEPEND_FAIL; do
        echo "Installing... $i"
        # sudo pacman -S $i
        sudo apt install -y "$i"
      done
      #exit -1
    fi
  fi
}

install_xflux() {
  cd fluxgui || exit 1
  ./download-xflux.py

  # EITHER install system wide
  sudo ./setup.py install --record installed.txt

  # EXCLUSIVE OR, install in your home directory
  #
  # The fluxgui program installs
  # into ~/.local/bin, so be sure to add that to your PATH if installing
  # locally. In particular, autostarting fluxgui in Gnome will not work
  # if the locally installed fluxgui is not on your PATH.
  ./setup.py install --user --record installed.txt
  cd ..
}

# TODO, get dependencies from a file
#libtinfo5 is needed for YCM
# ARCH
#DEPENDENCIES="git tmux vim zsh ctags cmake cscope parcellite docker guake gdb dialog wireshark-gtk meld valgrind sshpass shellcheck"
# Debian
DEPENDENCIES="git tmux vim zsh cmake cscope exuberant-ctags parcellite docker guake gdb dialog meld valgrind ca-certificates \
  curl sshpass shellcheck tree \
  gnupg \
  lsb-release \
  build-essential cmake vim-nox python3-dev mono-complete golang nodejs default-jdk npm \
  docker-ce docker-ce-cli containerd.io ninja-build
  "


# if [ ! -d /usr/share/keyrings/docker-archive-keyring.gpg ]; then
# 	curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# fi
#echo \
#  'deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
#  $(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

check_dependencies $DEPENDENCIES

git submodule update --init --recursive

type xflux > /dev/null 2>&1  || { echo "Installing xflux"; install_xflux; }

#change your default shell
if [ "$SHELL" != /bin/zsh ]; then
  chsh -s /bin/zsh
fi

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

if [ -d ~/.vim/bundle/Vundle.vim ]; then
  rm -rf ~/.vim/bundle/Vundle.vim_old 2>/dev/null
  echo "Copying your Vundle.vim in  ~/.vim/bundle/Vundle.vim_old"
  mv ~/.vim/bundle/Vundle.vim ~/.vim/bundle/Vundle.vim_old;
fi
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

fmv _vimrc ~/.vimrc
fmv _simple_vimrc ~/.simple_vimrc
fmv _tmux.conf ~/.tmux.conf
fmv _zshrc ~/.zshrc
fmv _gdbinit ~/.gdbinit
fmv tmux-resurrect/resurrect.tmux ~/.resurrect.tmux

chmod +x sshh_script

vim +PluginInstall +qall

# Be sure you have installed your python3.X-dev package

cd ~/.vim/bundle/YouCompleteMe
python3 install.py --all

