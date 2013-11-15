#!/bin/sh

###############################################################################

ITER=100;
MSIZE=250;
EDIR="exhibits"
MOTF="montage.png";
CLN_SEQ="clean_seq";

TIME=0.05
ORIG='GOLS_0_ORIG.png';
GRAY='GOLS_1_GRAY.png';
GSML='GOLS_2_GSML.png';
FRST='GOLS_3_0000000000.png';
SCND='GOLS_3_0000000001.png';
THRD='GOLS_3_0000000002.png';
###############################################################################

function make_montage() {

  local dir=$1;
  local outf=$2;
  local n=`ls $dir | grep '^GOLS_3_[0-9]*.png$' | wc -l`;

  local steps=("Original" "Grayscale" "Initial condition" "First step" "Second step");
  local lst="$ORIG $GRAY $FRST $SCND $THRD";

  local i=0;
  local P="";
  for img in $lst; do
    if [ -e "$dir/$img" ]; then
      local tmpi=`mktemp`".png";
      convert "$dir/$img" -resize 250x250\> -background Orange label:"${steps[i]}" -gravity Center -append $tmpi;
      P="$P $tmpi";
      i=$((i+1));
    fi
  done

  local P=($P);
  local np=${#P[@]};
  local size=`identify "${P[0]}" | cut -d\  -f3`;

  montage ${P[@]} -tile ${np}x1 -geometry $size+1+1 $outf;
  rm ${P[@]};

}

###############################################################################

function prepare_list() {
  local dir=$1;
  local time=$2;
  local n=`ls $dir | grep '^GOLS_3_[0-9]*.png$' | wc -l`;
  local s=`echo "1/$time" | bc`;

  local lst="$3";

  for i in `seq 1 $s`; do
    echo "$dir/$ORIG" >> $lst;
  done
  for i in `seq 1 $s`; do
    echo "$dir/$GRAY" >> $lst;
  done
  for i in `seq 1 $s`; do
    echo "$dir/$GSML" >> $lst;
  done
  for i in `seq 1 $s`; do
    echo "$dir/$FRST" >> $lst;
  done

  for i in `seq 1 $((n-1))`; do
    #fr=`echo "scale=1;((1/$time) * (1-(1/(1 + e(-($i-10)/10)) )))" | bc -l | cut -d. -f1`;
    #if [ $fr -eq 0 ]; then fr=1; fi
    #for j in `seq 1 $fr`; do
      printf "$dir/GOLS_3_%010d.png\n" $i >> $lst;
    #done
  done
}

###############################################################################

function make_exhibit() {

  local input=$1;
  local outdir=$2;
  local iter=$3;
  local msize=$4;

  rm -rf $outdir &> /dev/null;
  mkdir -p $outdir/$CLN_SEQ &> /dev/null;

  #############################################################################

  echo "Performing preprocessing"
  convert "$input" -resize ${msize}x${msize}\>               "$outdir/original.png";
  convert "$outdir/original.png"  -type Grayscale  "$outdir/grayscale.png";
  convert "$outdir/grayscale.png" -lat 3x3         "$outdir/threshold.png";
  convert "$outdir/threshold.png" -flip -rotate 90 "$outdir/threshold.txt";

  head    "$outdir/threshold.txt" -n1 | cut -d: -f2 | cut -d, -f1,2 | sed -e 's/ //g' >   "$outdir/IMG.RAW";
  cat     "$outdir/threshold.txt" | grep "#000000" | cut -d: -f1                      >> "$outdir/IMG.RAW";

  #############################################################################

  ./gol_wrapper.py "$outdir/IMG.RAW" "$outdir/$CLN_SEQ" "$iter";

  #############################################################################

  local i=0;
  ls "$outdir/$CLN_SEQ" | grep '^[0-9]*.png$' | while read img; do
    i=$((i+1));
    printf '\rProcess %010d/%d' $i $((iter+1));
    convert "$outdir/$CLN_SEQ/$img" -trim +repage -type Grayscale -normalize -negate "$outdir/$CLN_SEQ/GOLS_3_$img";
    cp "./$outdir/$CLN_SEQ/GOLS_3_$img" "$outdir/";
    rm "$outdir/$CLN_SEQ/$img";
  done
  local size=`identify "$outdir/$CLN_SEQ/GOLS_3_0000000000.png" | cut -d\  -f3`;
  echo "";

  convert "$input"                  -resize $size   "$outdir/$CLN_SEQ/$ORIG";
  cp "$outdir/$CLN_SEQ/$ORIG" "$outdir/";
  convert "$outdir/$CLN_SEQ/$ORIG" -type Grayscale "$outdir/$CLN_SEQ/$GRAY";
  cp "$outdir/$CLN_SEQ/$GRAY" "$outdir/";
  convert "$outdir/grayscale.png"   -sample $size   "$outdir/$CLN_SEQ/$GSML";
  cp "$outdir/$CLN_SEQ/$GSML" "$outdir/";

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
  echo "  montage <title> [outf] [exhibit_dir]";
  echo "    title:       The title of the exhibit";
  echo "    outf:        The output file (DEFAULT = $MOTF)";
  echo "    exhibit_dir: The input directory (DEFAULT = $EDIR)";
  echo "";
  echo "  effect <title> <effects> [exhibit_dir]";
  echo "    title:      The exhibit you wish to apply it to";
  echo "    effects:    The effects you with to apply (DEFAULT=$EFCTS)";
  echo "    exhbit_dir: The input directory (DEFAULT = $EDIR)";
  echo ""
  echo "Example usage";
  echo "  \$ $0 add lena.jpg lena # To add an image";
  echo "  \$ $0 start             # To display all images once";
  echo "  \$ $0 loop              # To display all images, forever";
  exit 1;
}

###############################################################################

source './effects.sh'

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

  "display")
    if [ $# -lt 1 ] || [ $# -gt 4 ]; then
      usage $0;
    fi

    edir=$2; if [ ! -n "$edir" ]; then edir=$EDIR; fi;
    time=$3; if [ ! -n "$time" ]; then time=$TIME; fi;
    loop=$4;
    lst=`mktemp`;
    echo -en "" > $lst;

    ls -t -d "$edir"/*/ | while read exhibit; do
      prepare_list $exhibit $time $lst;
    done
    feh $loop -D $time -F -Z --filelist $lst;
    rm $lst;
    ;;

  "start")
    edir=$2; if [ ! -n "$edir" ]; then edir=$EDIR; fi;
    time=$3; if [ ! -n "$time" ]; then time=$TIME; fi;
    $0 display $edir $time "--cycle-once";
    ;;
  "loop")
    edir=$2; if [ ! -n "$edir" ]; then edir=$EDIR; fi;
    time=$3; if [ ! -n "$time" ]; then time=$TIME; fi;
    $0 display $edir $time "";
    ;;

  "montage")
    if [ $# -lt 2 ] || [ $# -gt 4 ]; then
      usage $0;
    fi

    name=$2;
    motf=$3; if [ ! -n "$motf" ]; then motf=$MOTF; fi;
    edir=$4; if [ ! -n "$edir" ]; then edir=$EDIR; fi;
    make_montage "$edir/$name" $motf;
    ;;

  "effect")
    if [ $# -lt 2 ] || [ $# -gt 4 ]; then
      usage $0;
    fi

    name="$2";
    efcts="$3"; if [ ! -n "$efcts" ]; then efcts="$EFCTS"; fi;
    edir="$4";   if [ ! -n "$edir" ]; then edir=$EDIR; fi;
    for efct in `echo $efcts | tr ',' ' '`; do
      effect_$efct "$edir/$name";
    done
    ;;

  *)
    usage $0;
    ;;
esac;

exit 0
