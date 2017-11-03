#!/bin/bash

check_dependencies() {
  DEPEND_FAIL=0
  echo "Dependencies:"
  for i in $@; do
    { type $i > /dev/null 2>&1 && echo "$i PASS"; } ||
    {  echo "$i FAIL"; DEPEND_FAIL=1; }
  done

  if [ $DEPEND_FAIL -eq 1 ]; then
    exit -1
  fi
}

fmv() {
  cp $2 $2.bk 2> /dev/null
  rm $2 2> /dev/null
  #SELECT COPY OF LN
  ln -s $(realpath $1) $2
  #  cp $1 $2
}

DEPENDENCIES="tmux vim zsh ctags"
check_dependencies $DEPENDENCIES

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
  mv ~/.vim/bundle/Vundle.vim ~/.vim/bundle/Vundle.vim_old;
fi
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

fmv _vimrc ~/.vimrc
fmv _tmux.conf ~/.tmux.conf
fmv _zshrc ~/.zshrc
chmod +x sshh_script

vim +PluginInstall +qall


