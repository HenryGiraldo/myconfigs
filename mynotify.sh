#Jesus Fernandez cortesy

myalert() {
  if [ $? = 0 ]; then
    notify-send --urgency=low -i face-wink "Done: $(history|tail -n1| awk '{$1 = ""; print $0}')"
  else
    notify-send --urgency=low -i face-angry "Fail: $(history|tail -n1| awk '{$1 = ""; print $0}')"
  fi
}
