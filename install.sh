#/bin/bash
DEPENDENCIES="tmux vim zsh"

for i in $DEPENDENCIES; do
  type $i > /dev/null 2>&1 || {
  echo "I requiere $DEPENDENCIES, at least $i i not installed"
  }
done

fmv() {
  cp $2 $2.bk
  rm $2
#SELECT COPY OF LN
  ln -s $1 $2
#  cp $1 $2
}

fmv _vimrc ~/.vimrc
fmv _tmux.conf ~/.tmux.conf
fmv _zshrc ~/.zshrc
chmod +x sshh_script

#change your default shell
if [ $SHELL != /bin/zsh ]; then
  chsh -s /bin/zsh
fi

if [ ! -d /usr/share/oh-my-zsh ]; then
  git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
  cp ~/.oh-my-zsh /usr/share/oh-my-zsh
fi

