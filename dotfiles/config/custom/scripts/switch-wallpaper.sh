#! /bin/sh

# constants
tmpfile="/tmp/current_wallpaper"
wallpaperdir="/home/bazoo/.wallpapers"
wallpapercolorsfile="$wallpaperdir/.colors"

getvalueat()
{
  value=$(cut -d',' -f$2 <<< $1)
}

getrowinfo()
{
  row=$1
  # filename,leftfg,centerfg,rightfg,bgcolor,procolor1,procolor2
  getvalueat $row 1
  filename=$value

  getvalueat $row 2
  leftfg=$value

  getvalueat $row 3
  centerfg=$value

  getvalueat $row 4
  rightfg=$value

  getvalueat $row 5
  bgcolor=$value

  getvalueat $row 6
  procolor1=$value

  getvalueat $row 7
  procolor2=$value
}

# generate colors
/home/bazoo/.config/custom/scripts/generate-wallpaper-colors.sh

if [ -z $1 ]; then
  # get random wallpaper
  row=`cat $wallpapercolorsfile | sort -R | tail -1`
  getrowinfo $row
  img=$filename

  # get different wallpaper than current one
  if [ -f $tmpfile ]; then
    currentwallpaper=`cat $tmpfile`
    while [ $currentwallpaper == $img ]; do
      row=`cat $wallpapercolorsfile | sort -R | tail -1`
      getrowinfo $row
      img=$filename
    done
  fi
else
  row=$(cat $wallpapercolorsfile | grep $1)
  getrowinfo $row
  img=$filename
fi

# Save wallpaper to cache
echo $img > $tmpfile

wallpaperfile="$wallpaperdir/$img"

echo $wallpaperfile

# Export colors
export POLYBAR_FGLEFT="#$leftfg"
export POLYBAR_FGCENTER="#$centerfg"
export POLYBAR_FGRIGHT="#$rightfg"
export POLYBAR_BGCOLOR="#$bgcolor"

# Change wallpaper
feh $wallpaperfile --bg-scale &

# Reload polybar
/home/bazoo/.config/polybar/launch.sh &

# Setup lock
/home/bazoo/.config/custom/scripts/lock_setup.sh $wallpaperfile $procolor1 $procolor2
