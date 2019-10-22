#! /bin/sh

tmpfile="/tmp/lock.png"
tmpwall="/tmp/wallpaper.png"
tmpprocolors="/tmp/prominent_colors"
radius=30
xpos=90
ypos=90

# Get screenshot
cp $tmpwall $tmpfile

# Suspend dunst
pkill -u $USER -USR1 dunst

# Get colors
maincolor=`head -1 $tmpprocolors`
negcolor=`tail -1 $tmpprocolors`
opacity="ff"
maincolor="$maincolor$opacity"
negcolor="$negcolor$opacity"

i3lock -k -i $tmpfile \
	--insidecolor=00000000 \
	--ringcolor=$maincolor \
	--line-uses-inside \
	--keyhlcolor=$negcolor \
	--bshlcolor=$negcolor \
	--separatorcolor=00000000 \
	--insidevercolor=00000000 \
	--insidewrongcolor=00000000 \
	--ringvercolor=fecf4dff \
	--ringwrongcolor=d23c3dff \
	--radius=$radius \
	--ring-width=3 \
	--indpos="x+$xpos:y+h-$ypos" \
	--timepos="x+ix+r+r:y+iy" \
	--datepos="x+tx:y+ty+r" \
  --timestr="%I:%M %p" \
	--timecolor=$maincolor \
	--datecolor=$maincolor \
	--time-font="Ubuntu" \
	--date-font="Ubuntu" \
	--time-align=1 \
	--date-align=1 \
	--veriftext="" \
	--wrongtext=""

pkill -u $USER -USR2 dunst
rm $tmpfile
