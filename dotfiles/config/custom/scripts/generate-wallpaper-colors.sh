#! /bin/sh

# constants
defaultbgcolor="00000000"
wallpaperdir="/home/bazoo/.wallpapers"
wallpapercolorsfile="$wallpaperdir/.colors"

# gets foreground color for the top bar
getfgcolor()
{
	fgcolor=`convert $1 -gravity $2 -negate -crop $3%x$4%x+0+0 -colorspace gray -resize 1x1 -format '%[hex:p{0,0}]' info:-`
}

# gets background color for the top bar
getbgcolor()
{
  wallpaperfile="$1"
  # defaults to default bgcolor
  bgcolor="$defaultbgcolor"

  contrast=`convert $wallpaperfile -gravity North -crop 100x5%x+0+0 -colorspace gray -format '%[fx:standard_deviation]' info:-`
  if (( $(echo "$contrast 0.2" | awk '{print ($1 > $2)}') )); then
    bgcolor=`convert $wallpaperfile -gravity North -crop 100x5%+0+0 -resize 1x1 -format '%[hex:p{0,0}]' info:-`
    bgcolor="20$bgcolor"
  fi
}

# get prominent color for the wallpaper
getprominentcolor()
{
	procolor=`convert $1 -colorspace rgb +dither -colors 5 -unique-colors -format "%[hex:p{$2,0}]" info:-`
}

# creates a row with the following format
# filename,leftfg,centerfg,rightfg,bgcolor,procolor1,procolor2
getrow()
{
  file="$1"
  wallpaperfile="$wallpaperdir/$file"

  getfgcolor $wallpaperfile NorthEast 15 5
  leftfg=$fgcolor

  getfgcolor $wallpaperfile North 30 5
  centerfg=$fgcolor

  getfgcolor $wallpaperfile NorthWest 20 5
  rightfg=$fgcolor

  getbgcolor $wallpaperfile
  bgcolor=$bgcolor

  getprominentcolor $wallpaperfile 4
  procolor1=$procolor

  getprominentcolor $wallpaperfile 0
  procolor2=$procolor

  row="$file,$leftfg,$centerfg,$rightfg,$bgcolor,$procolor1,$procolor2"
}

if [ "$1" == "reset" ]; then
  echo "Regenerating all wallpaper colors..."
  rm $wallpapercolorsfile
fi

if [ ! -f $wallpapercolorsfile ]; then
  touch $wallpapercolorsfile
fi

for wallpaper in $(ls $wallpaperdir); do
  # only generate if wallpaper is not in the color file
  if [ -z $(cat $wallpapercolorsfile | grep $wallpaper) ]; then
    getrow $wallpaper
    echo $row >> $wallpapercolorsfile
  fi
done
