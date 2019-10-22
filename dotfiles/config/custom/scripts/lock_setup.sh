#! /bin/sh

lockicon="/home/bazoo/.config/custom/assets/lock.png"
tmpwall="/tmp/wallpaper.png"
tmpprocolors="/tmp/prominent_colors"
tmplock="/tmp/lockicon.png"

# $1 -> wallpaper
# $2 -> procolor1
# $3 -> procolor2

wallpaperfile=$1
procolor1=$2
procolor2=$3

# Get prominent colors
echo $procolor1 > $tmpprocolors
echo $procolor2 >> $tmpprocolors

# Convert image
convert $wallpaperfile -resize 1366x768^ $tmpwall

if [ -f $lockicon ]; then
	color="#$procolor1"
	convert $lockicon -resize 30x30 -fill $color -colorize 100% $tmplock
	convert $tmpwall $tmplock -gravity SouthWest -geometry +75+75 -composite -matte $tmpwall
	rm $tmplock
fi
