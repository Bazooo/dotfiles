#! /bin/sh

pipfile="piplist.txt"
paclist="pkglist.txt"
npmfile="npmlist.txt"

if [ -z "$1" ]; then
  path="."
else
  path="$1"
fi

echo "making pip list..."
pip freeze > "$path/$pipfile"

echo "making pacman list"
yay -Qqe > "$path/$paclist"

echo "making npm list..."
npm list -g --depth 0 > "$path/$npmfile"
