#!/bin/bash

check_dependencies() {
  DEPEND_FAIL=
  echo "Dependencies:"
  for i in $@; do
    { type $i > /dev/null 2>&1 && echo "$i PASS"; } ||
    { echo "$i FAIL"; DEPEND_FAIL="$DEPEND_FAIL $i"; }
  done

  if [ ! -z "$DEPEND_FAIL" ]; then
    echo "Do you want to install all missing dependencies? [Y/n]"
    read want_install
    if echo "$want_install" | grep -iq "^n"; then
      exit -1
    else
      for i in $DEPEND_FAIL; do
        echo "Installing... $i"
        sudo pacman -S $i
      done
      exit -1
    fi
  fi
}

install_xflux() {
  cd fluxgui
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

fmv() {
  cp $2 $2.bk 2> /dev/null
  rm $2 2> /dev/null
  #SELECT COPY OF LN
  ln -s $(realpath $1) $2
  #  cp $1 $2
}

#libtinfo5 is needed for YCM
DEPENDENCIES="git tmux vim zsh ctags cmake cscope parcellite docker guake gdb dialog wireshark-gtk meld valgrind"
check_dependencies $DEPENDENCIES

git submodule update --init --recursive

type xflux > /dev/null 2>&1  || { echo "Installing xflux"; install_xflux; }

#change your default shell
if [ $SHELL != /bin/zsh ]; then
  chsh -s /bin/zsh
fi

if [ ! -d /usr/share/oh-my-zsh ]; then
  if [ -d ~/.oh-my-zsh ]; then mv ~/.oh-my-zsh ~/.oh-my-zsh_old; fi
  git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
  sudo cp -r ~/.oh-my-zsh /usr/share/oh-my-zsh
fi

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

