#! /bin/sh

getprominentcolor()
{
	procolor=`convert $wallpaperfile -colorspace rgb +dither -colors 5 -unique-colors -format "%[hex:p{$1,0}]" info:-`
}

# $1 -> wallpaper

wallpaperfile=$1
lockicon="/home/bazoo/.config/custom/assets/lock.png"
tmpwall="/tmp/wallpaper.png"
tmpprocolors="/tmp/prominent_colors"
tmplock="/tmp/lockicon.png"

# Get prominent colors
getprominentcolor 4
maincolor=$procolor
echo $procolor > $tmpprocolors
getprominentcolor 1
echo $procolor >> $tmpprocolors

# Convert image
convert $wallpaperfile -resize 1366x768^ $tmpwall

if [ -f $lockicon ]; then
	color="#$maincolor"
	convert $lockicon -resize 30x30 -fill $color -colorize 100% $tmplock
	convert $tmpwall $tmplock -gravity SouthWest -geometry +75+75 -composite -matte $tmpwall
	rm $tmplock
fi
