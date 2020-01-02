#!/bin/bash
#
# Developed by Fred Weinhaus 8/3/2016 .......... revised 9/9/2018
# 
# ------------------------------------------------------------------------------
# 
# Licensing:
# 
# Copyright © Fred Weinhaus
# 
# My scripts are available free of charge for non-commercial use, ONLY.
# 
# For use of my scripts in commercial (for-profit) environments or 
# non-free applications, please contact me (Fred Weinhaus) for 
# licensing arrangements. My email address is fmw at alink dot net.
# 
# If you: 1) redistribute, 2) incorporate any of these scripts into other 
# free applications or 3) reprogram them in another scripting language, 
# then you must contact me for permission, especially if the result might 
# be used in a commercial or for-profit environment.
# 
# My scripts are also subject, in a subordinate manner, to the ImageMagick 
# license, which can be found at: http://www.imagemagick.org/script/license.php
# 
# ------------------------------------------------------------------------------
# 
####
#
# USAGE: dominantcolor [-m mode] [-n numcolors] [-e excludecolor] 
# [-f fuzzval] [-p print] [-s swatches] infile
# USAGE: dominantcolor [-h or -help]
# 
# OPTIONS:
# 
# -m     mode             mode of processing; options are: 1=unrestricted  
#                         colors, 2=exclude black, 3=exclude white, 4=exclude 
#                         any color, 5=only high saturation colors, 6=only   
#                         high saturation and brightness colors; default=1
# -n     numcolors        number of colors to consider during color reduction;
#                         integer>1; default=6
# -e     excludecolor     exclude color to be ignored in getting dominant
#                         color; any valid opaque IM color; default=black 
# -f     fuzzval          fuzz value for modes 2-6; smaller values select 
#                         colors closer to the mode desired, but may lead 
#                         to less than the selected numcolors; 0<=integer<=100; 
#                         default=50
# -p     print            print options: all (hexcolors and counts for all 
#                         numcolors) or dominant (only the hexcolor for the 
#                         dominant color; default=dominant
# -s     swatches         view or save swatches for option -p print; view or save; 
#                         default is no swatches
# 
###
# 
# NAME: DOMINANTCOLOR 
# 
# PURPOSE: To find the dominant color in an image.
# 
# DESCRIPTION: Finds the dominant color or selected number of colors in an 
# image. Modifiers can be used to restrict colors in the image. The alpha 
# channel will be disabled for this script.
# 
# 
# ARGUMENTS: 
# 
# -m mode ... MODE of processing. The options are: 1=unrestricted colors, 
# 2=exclude black, 3=exclude white, 4=exclude any color, 5=only high 
# saturation colors, 6=only high saturation and brightness colors. The 
# default=1.
# 
# -n numcolors ... NUMCOLORS is the number of colors to consider during 
# color reduction. Values are integers>1. The default=6.
# 
# -e excludecolor ... EXCLUDECOLOR is an exclude color to be ignored in 
# getting the dominant color. Any valid opaque IM color. The default=black for 
# -m 4; otherwise, not used.
# 
# -f fuzzval ... FUZZVAL is the fuzz value for modes 2-6. Smaller values  
# select colors closer to the mode desired, but may lead to less than the 
# selected numcolors. Values are 0<=integers<=100; The default=50.
# 
# -p print ... PRINT options: all (hexcolors and counts for all numcolors) or 
# dominant (only the hexcolor for the dominant color. The default=dominant.
# 
# -s swatches ... view or save SWATCHES for option -p print. Choices are: view (v) 
# or save (s). The default is no swatches. If save, then the output will be named 
# with either _dominantcolor or _swatches appended to the input name as a gif image. 
# 
# CAVEAT: No guarantee that this script will work on all platforms, 
# nor that trapping of inconsistent parameters is complete and 
# foolproof. Use At Your Own Risk. 
# 
######
# 

# set default values
mode=1				# mode=1,2,3,4,5,6
numcolors=6			# integer>1
ecolor="black"		# exclude color
fuzzval=50			# fuzz value
print="dominant"	# all hexcolors or dominant hexcolor
swatches=""		    # view swatches; view or save

# set directory for temporary files
dir="."    # suggestions are dir="." or dir="/tmp"

# set up functions to report Usage and Usage with Description
PROGNAME=`type $0 | awk '{print $3}'`  # search for executable on path
PROGDIR=`dirname $PROGNAME`            # extract directory of program
PROGNAME=`basename $PROGNAME`          # base name of program
usage1() 
	{
	echo >&2 ""
	echo >&2 "$PROGNAME:" "$@"
	sed >&2 -e '1,/^####/d;  /^###/g;  /^#/!q;  s/^#//;  s/^ //;  4,$p' "$PROGDIR/$PROGNAME"
	}
usage2() 
	{
	echo >&2 ""
	echo >&2 "$PROGNAME:" "$@"
	sed >&2 -e '1,/^####/d;  /^######/g;  /^#/!q;  s/^#*//;  s/^ //;  4,$p' "$PROGDIR/$PROGNAME"
	}


# function to report error messages
errMsg()
	{
	echo ""
	echo $1
	echo ""
	usage1
	exit 1
	}


# function to test for minus at start of value of second part of option 1 or 2
checkMinus()
	{
	test=`echo "$1" | grep -c '^-.*$'`   # returns 1 if match; 0 otherwise
    [ $test -eq 1 ] && errMsg "$errorMsg"
	}

# test for correct number of arguments and get values
if [ $# -eq 0 ]
	then
	# help information
   echo ""
   usage2
   exit 0
elif [ $# -gt 13 ]
	then
	errMsg "--- TOO MANY ARGUMENTS WERE PROVIDED ---"
else
	while [ $# -gt 0 ]
		do
			# get parameter values
			case "$1" in
		  -h|-help)    # help information
					   echo ""
					   usage2
					   exit 0
					   ;;
				-m)    # get mode
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID MODE SPECIFICATION ---"
					   checkMinus "$1"
					   mode=`expr "$1" : '\([0-9]*\)'`
					   [ "$mode" = "" ] && errMsg "--- MODE=$mode MUST BE A NON-NEGATIVE INTEGER ---"
					   test1=`echo "$mode < 1" | bc`
					   test2=`echo "$mode > 6" | bc`
					   [ $test1 -eq 1 -o $test2 -eq 1 ] && errMsg "--- MODE=$mode MUST BE AN INTEGER BETWEEN 1 AND 6 ---"
					   ;;
				-n)    # get  numcolors
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID NUMCOLORS SPECIFICATION ---"
					   checkMinus "$1"
					   numcolors=`expr "$1" : '\([0-9]*\)'`
					   [ "$numcolors" = "" ] && errMsg "--- NUMCOLORS=$numcolors MUST BE A NON-NEGATIVE INTEGER ---"
					   test1=`echo "$numcolors < 2" | bc`
					   test2=`echo "$numcolors > 256" | bc`
					   [ $test1 -eq 1 -o $test2 -eq 1 ] && errMsg "--- NUMCOLORS=$numcolors MUST BE AN INTEGER BETWEEN 2 AND 256 ---"
					   ;;
				-e)    # get excludecolor
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID EXCLUDECOLOR SPECIFICATION ---"
					   checkMinus "$1"
					   excludecolor="$1"
					   ;;
				-f)    # get fuzzval
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID FUZZVAL SPECIFICATION ---"
					   checkMinus "$1"
					   fuzzval=`expr "$1" : '\([0-9]*\)'`
					   [ "$fuzzval" = "" ] && errMsg "--- FUZZVAL=$fuzzval MUST BE A NON-NEGATIVE INTEGER VALUE (with no sign) ---"
					   test1=`echo "$fuzzval < 0" | bc`
					   test2=`echo "$fuzzval > 100" | bc`
					   [ $test1 -eq 1 -o $test2 -eq 1 ] && errMsg "--- FUZZVAL=$fuzzval MUST BE AN INTEGER BETWEEN 0 AND 100 ---"
					   ;;
				-p)    # print
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID PRINT SPECIFICATION ---"
					   checkMinus "$1"
					   print=`echo "$1" | tr "[:upper:]" "[:lower:]"`
					   case "$print" in 
							all|a) print="all" ;;
							dominant|d) print="dominant" ;;
							*) errMsg "--- PRINT=$print IS AN INVALID VALUE ---" 
					   esac
				   	   ;;
				-s)    # swatches
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID SWATCHES SPECIFICATION ---"
					   checkMinus "$1"
					   swatches=`echo "$1" | tr "[:upper:]" "[:lower:]"`
					   case "$swatches" in 
							view|v) swatches="view" ;;
							save|s) swatches="save" ;;
							*) errMsg "--- SWATCHES=$swatches IS AN INVALID VALUE ---" 
					   esac
				   	   ;;
				 -)    # STDIN and end of arguments
					   break
					   ;;
				-*)    # any other - argument
					   errMsg "--- UNKNOWN OPTION ---"
					   ;;
		     	 *)    # end of arguments
					   break
					   ;;
			esac
			shift   # next option
	done
	#
	# get infile and outfile
	infile="$1"
	outfile="$2"
fi

# test that infile provided
[ "$infile" = "" ] && errMsg "NO INPUT FILE SPECIFIED"

inname=`convert -ping "$infile" -format "%t" info:`

# setup temporary images
tmpA1="$dir/dominantcolor_1_$$.mpc"
tmpB1="$dir/dominantcolor_1_$$.cache"
trap "rm -f $tmpA1 $tmpB1 $tmpA2; exit 0" 0
trap "rm -f $tmpA1 $tmpB1 $tmpA2; exit 1" 1 2 3 15


# read the input image into the temporary cached image and test if valid
convert -quiet -regard-warnings "$infile" -alpha off +repage "$tmpA1" ||
	errMsg "--- FILE $infile DOES NOT EXIST OR IS NOT AN ORDINARY FILE, NOT READABLE OR HAS ZERO size  ---"


if [ $mode -eq 1 ]; then
	sortedfinalcolors=`convert $tmpA1 -scale 50x50! -depth 8 \
		+dither -colors $numcolors -depth 8 -format "%c" histogram:info: |\
		sed -n 's/^[ ]*\(.*\):.*[#]\([0-9a-fA-F]*\) .*$/\1,#\2/p' | sort -r -n -k 1 -t ","`
elif [ $mode -eq 2 ]; then
	sortedfinalcolors=`convert $tmpA1 -scale 50x50! -depth 8 \
		-fuzz $fuzzval% -transparent black sparse-color:- |\
		convert -size 50x50 xc: -sparse-color voronoi '@-' \
		+dither -colors $numcolors -depth 8 -format "%c" histogram:info: |\
		sed -n 's/^[ ]*\(.*\):.*[#]\([0-9a-fA-F]*\) .*$/\1,#\2/p' | sort -r -n -k 1 -t ","`
elif [ $mode -eq 3 ]; then
	sortedfinalcolors=`convert $tmpA1 -scale 50x50! -depth 8 \
		-fuzz $fuzzval% -transparent white sparse-color:- |\
		convert -size 50x50 xc: -sparse-color voronoi '@-' \
		+dither -colors $numcolors -depth 8 -format "%c" histogram:info: |\
		sed -n 's/^[ ]*\(.*\):.*[#]\([0-9a-fA-F]*\) .*$/\1,#\2/p' | sort -r -n -k 1 -t ","`
elif [ $mode -eq 4 ]; then
	sortedfinalcolors=`convert $tmpA1 -scale 50x50! -depth 8 \
		-fuzz $fuzzval% -transparent $ecolor sparse-color:- |\
		convert -size 50x50 xc: -sparse-color voronoi '@-' \
		+dither -colors $numcolors -depth 8 -format "%c" histogram:info: |\
		sed -n 's/^[ ]*\(.*\):.*[#]\([0-9a-fA-F]*\) .*$/\1,#\2/p' | sort -r -n -k 1 -t ","`
elif [ $mode -eq 5 ]; then
	thresh=$((100-fuzzval))
	sortedfinalcolors=`convert $tmpA1 -scale 50x50! -depth 8 \
		\( -clone 0 -colorspace HSB -channel g -separate +channel -threshold $thresh% \) \
		-alpha off -compose copy_opacity -composite sparse-color:- |\
		convert -size 50x50 xc: -sparse-color voronoi '@-' \
		+dither -colors $numcolors -depth 8 -format "%c" histogram:info: |\
		sed -n 's/^[ ]*\(.*\):.*[#]\([0-9a-fA-F]*\) .*$/\1,#\2/p' | sort -r -n -k 1 -t ","`
elif [ $mode -eq 6 ]; then
	thresh=$((100-fuzzval))
	sortedfinalcolors=`convert $tmpA1 -scale 50x50! -depth 8 \
	\( -clone 0 -colorspace HSB -channel gb -separate +channel -threshold $thresh% \
	-compose multiply -composite \) \
	-alpha off -compose copy_opacity -composite sparse-color:- |\
	convert -size 50x50 xc: -sparse-color voronoi '@-' \
	+dither -colors $numcolors -depth 8 -format "%c" histogram:info: |\
	sed -n 's/^[ ]*\(.*\):.*[#]\([0-9a-fA-F]*\) .*$/\1,#\2/p' | sort -r -n -k 1 -t ","`
fi


if [ "$print" = "dominant" ]; then
	dominantcolor=`echo "$sortedfinalcolors" | head -n 1 | cut -d, -f2`
	echo "$dominantcolor"
	if [ "$swatches" != "" ]; then
		if [ "$swatches" = "view" ]; then
			action="show:"
		elif [ "$swatches" = "save" ]; then
			action="${inname}_dominantcolor.gif"
		fi
		convert xc:"$dominantcolor" -scale 5000% $action
	fi
elif [ "$print" = "all" ]; then
	echo "dominant colors:"
	echo "count,hexcolor"
	echo "$sortedfinalcolors"
	if [ "$swatches" != "" ]; then
		swatch_list=""
		for item in $sortedfinalcolors; do
			color=`echo "$item" | cut -d, -f2`
			pixel="xc:'$color'"
			swatch_list="$swatch_list $pixel"
		done
		if [ "$swatches" = "view" ]; then
			action="show:"
		elif [ "$swatches" = "save" ]; then
			action="${inname}_swatches.gif"
		fi
		eval 'convert '$swatch_list' +append -scale 5000% $action'
	fi
fi


exit 0
