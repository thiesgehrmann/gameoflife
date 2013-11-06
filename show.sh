#!/bin/sh

###############################################################################

ITER=100;
MSIZE=250;
EDIR="exhibits"

TIME=0.2
ORIG='GOLS_0_ORIG.png';
GRAY='GOLS_1_GRAY.png';
GSML='GOLS_2_GSML.png';
FRST='GOLS_3_0000000000.png';

###############################################################################

function prepare_list() {
  dir=$1;
  n=`ls $dir | grep '^GOLS_3_[0-9]*.png$' | wc -l`;

  for i in `seq 1 5`; do
    echo "$dir/$ORIG";
  done
  for i in `seq 1 5`; do
    echo "$dir/$GRAY"
  done
  for i in `seq 1 5`; do
    echo "$dir/$GSML"
  done
  for i in `seq 1 5`; do
    echo "$dir/$FRST";
  done

  for i in `seq 1 $((n-1))`; do
    printf "$dir/GOLS_3_%010d.png\n" $i;
  done

}

###############################################################################

function make_exhibit() {

  local input=$1;
  local outdir=$2;
  local iter=$3;
  local msize=$4;

  rm -rf $outdir &> /dev/null;
  mkdir -p $outdir &> /dev/null;

  #############################################################################

  echo "Performing preprocessing"
  convert "$input" -resize ${msize}x${msize}\>               "$outdir/original.png";
  convert "$outdir/original.png"  -type Grayscale  "$outdir/grayscale.png";
  convert "$outdir/grayscale.png" -lat 3x3         "$outdir/threshold.png";
  convert "$outdir/threshold.png" -flip -rotate 90 "$outdir/threshold.txt";

  head    "$outdir/threshold.txt" -n1 | cut -d: -f2 | cut -d, -f1,2 | sed -e 's/ //g' >   "$outdir/IMG.RAW";
  cat     "$outdir/threshold.txt" | grep "#000000" | cut -d: -f1                      >> "$outdir/IMG.RAW";

  #############################################################################

  ./gol_wrapper.py "$outdir/IMG.RAW" "$outdir" "$iter";

  #############################################################################

  local i=0;
  ls "$outdir" | grep '^[0-9]*.png$' | while read img; do
    i=$((i+1));
    printf '\rProcess %010d/%d' $i $((iter+1));
    convert "$outdir/$img" -trim -threshold 10% -negate "$outdir/GOLS_3_$img";
    rm "$outdir/$img";
  done
  local size=`identify "$outdir/GOLS_3_0000000000.png" | cut -d\  -f3`;
  echo "";

  convert "$input"                  -resize $size   "$outdir/GOLS_0_ORIG.png";
  convert "$outdir/GOLS_0_ORIG.png" -type Grayscale "$outdir/GOLS_1_GRAY.png";
  convert "$outdir/grayscale.png"   -resize $size   "$outdir/GOLS_2_GSML.png";

}

###############################################################################

function usage() {

  echo "Usage: $0 <task> [arguments]";
  echo "";
  echo "Tasks";
  echo "  add <image> <title> [iter] [msize] [exhibit_dir]";
  echo "    image:       The image you wish to add";
  echo "    title:       The title of the exhibit";
  echo "    exhibit_dir: The output directory (DEFAULT = $EDIR)";
  echo "    iter:        The number of iterations to perform (DEFAULT = $ITER)";
  echo "    msize:       The maximum size of the image (DEFAULT = $MSIZE)";
  echo "";
  echo "  start [exhibit_dir] [time]";
  echo "    exhibit_dir: The input directory (DEFAULT = $EDIR)";
  echo "    time:        The seconds delay between images in slideshow (DEFAULT = $TIME)";
  echo "";
  echo "  loop [exhibit_dir] [time]";
  echo "    exhibit_dir: The input directory (DEFAULT = $EDIR)";
  echo "    time:        The seconds delay between images in slideshow (DEFAULT = $TIME)";
  echo "";
  echo "  end";
  echo "    Due to the way feh works, if you start a loop, you must end it like this.";
  echo "";
  echo "Example usage";
  echo "  \$ $0 add lena.jpg lena # To add an image";
  echo "  \$ $0 start             # To display all images once";
  echo "  \$ $0 loop              # To display all images, forever";
  exit 1;
}

###############################################################################

task=$1;

case "$task" in
  "add")
   if [ $# -lt 3 ] || [ $# -gt 6 ]; then
     usage $0;
   fi

    img=$2;
    name=$3;
    iter=$4;  if [ ! -n "$iter"  ]; then iter=$ITER;   fi;
    msize=$5; if [ ! -n "$msize" ]; then msize=$MSIZE; fi;
    edir=$6;  if [ ! -n "$edir"  ]; then edir=$EDIR; fi;
    make_exhibit "$img" "$edir/$name" "$iter" "$msize";
    ;;

  "start")
    if [ $# -lt 1 ] || [ $# -gt 3 ]; then
      usage $0;
    fi

    edir=$2; if [ ! -n "$edir" ]; then edir=$EDIR; fi;
    time=$3; if [ ! -n "$time" ]; then time=$TIME; fi;
    ls -t -d "$edir"/*/ | while read exhibit; do
      feh -D $time -F -Z --cycle-once `prepare_list $exhibit`;
    done
    ;;

  "loop")
    while [ True ]; do
      $0 start $2 $3;
    done
    ;;
   "end")

     ps x -o  "%r %c" | grep show.sh | awk '{print $1;}' | uniq | while read g;
       do kill -9 "-$g";
     done
     ;;
  *)
    usage $0;
    ;;
esac;

exit 0
