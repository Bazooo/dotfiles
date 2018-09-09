#! /bin/sh

getfgcolor()
{
	fgcolor=`convert $wallpaperfile -gravity $1 -negate -crop $2%x$3%x+0+0 -colorspace gray -resize 1x1 -format '%[hex:p{0,0}]' info:-`
	fgcolor="#$fgcolor"
}

tmpfile="/tmp/current_wallpaper"
wallpaperdir="/home/bazoo/.wallpapers"

# Get random wallpaper
img=`ls $wallpaperdir | sort -R | tail -1`

if [ -f $tmpfile ]; then
	currentwallpaper=`cat $tmpfile`
	while [ $currentwallpaper == $img ]
       	do
		img=`ls $wallpaperdir | sort -R | tail -1`
	done
fi

# Save wallpaper to cache
echo $img > $tmpfile

wallpaperfile="$wallpaperdir/$img"

# Colors
getfgcolor NorthEast 15 5
leftfg=$fgcolor
getfgcolor North 30 5
centerfg=$fgcolor
getfgcolor NorthWest 20 5
rightfg=$fgcolor
bgcolor='#00000000'

contrast=`convert $wallpaperfile -gravity North -crop 100x5%x+0+0 -colorspace gray -format '%[fx:standard_deviation]' info:-`

if (( $(echo "$contrast 0.2" | awk '{print ($1 > $2)}') )); then
	bgcolor=`convert $wallpaperfile -gravity North -crop 100x5%+0+0 resize 1x1 -format '%[hex:p{0,0}]' info:-`
	bgcolor="#20$bgcolor"
fi

# Export colors
export POLYBAR_FGLEFT=$leftfg
export POLYBAR_FGCENTER=$centerfg
export POLYBAR_FGRIGHT=$rightfg
export POLYBAR_BGCOLOR=$bgcolor

# Change wallpaper
feh $wallpaperfile --bg-scale &

# Reload polybar
/home/bazoo/.config/polybar/launch.sh &

# Setup lock
/home/bazoo/.config/custom/scripts/lock_setup.sh $wallpaperfile 
