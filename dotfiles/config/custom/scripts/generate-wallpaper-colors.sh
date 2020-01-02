#! /bin/sh

# constants
defaultbgcolor="00000000"
wallpaperdir="/home/bazoo/.wallpapers"
wallpapercolorsfile="$wallpaperdir/.colors"
dominantcolorscript="/home/bazoo/.config/custom/scripts/dominantcolor.sh"

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

# get lightness color of a part of the image
getquarterlightness()
{
  width=`convert $1 -ping -format "%w" info:-`
  height=`convert $1 -ping -format "%h" info:-`
  width=`awk "BEGIN{print $width/2}"`
  height=`awk "BEGIN{print $height/2}"`
  quarterlightness=`convert $1 -gravity $2 -crop $width%x$height%x+0+0 -resize 1x1 -fx lightness -format '%[fx:p{0,0}]' info:-`
}

getoppositecolor()
{
  oppcolor=`convert xc:#$1 -negate -depth 8 -format "%[hex:p{0,0}]" info:-`
}

getdominantcolors()
{
  results=`$dominantcolorscript -m 6 -n $2 -f 50 -p all $1 | grep "#"`
  domcolors=""

  while read -r result; do
    domcolor=`echo $result | awk -F '#' '{print $2}'`
    domcolorlight=`convert xc:#$domcolor -fx lightness -format "%[fx:p{0,0}]" info:-`
    if [ -z $domcolors ]; then
      domcolors="$domcolor|$domcolorlight"
    else
      domcolors="$domcolors,$domcolor|$domcolorlight"
    fi
  done <<< $results

}

# get prominent color for the wallpaper
getprominentcolors()
{
  # get mean color of the south west quarter
  getquarterlightness $1 SouthWest
  quarterlightness=$quarterlightness

  getdominantcolors $1 6
  domcolorlights=$domcolors

  bestdifflight=0
  procolor1='000000'
  procolor2='000000'

  for domcolorlight in $(echo $domcolorlights | sed "s/,/ /g"); do
    domcolor=`echo $domcolorlight | awk -F "|" '{print $1}'`
    domlight=`echo $domcolorlight | awk -F "|" '{print $2}'`

    difflight=`awk "BEGIN{print sqrt(($domlight-$quarterlightness)^2)}"`

    if (( $(echo "$difflight $bestdifflight" | awk '{print ($1 > $2)}') )); then
      bestdifflight=$difflight
      procolor1=$domcolor
    fi
  done
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

  getprominentcolors $wallpaperfile

  getoppositecolor $procolor1
  procolor2=$oppcolor

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
  if [ -z "$(cat $wallpapercolorsfile | grep $wallpaper)" ]; then
    getrow $wallpaper
    echo $row >> $wallpapercolorsfile
  fi
done

exit 0
