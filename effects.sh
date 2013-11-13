#!/bin/sh

EFCTS="fade overlay multiply reset";

###############################################################################

function effect_fade() {
  local tdir="$1";
  local n=`ls $dir | grep '^GOLS_3_[0-9]*.png$' | wc -l`;

  i=100
  for img in `ls $tdir | grep '^GOLS_3_[0-9]*.png$' | sort | tail -n10`; do
    convert "$tdir/$img" -level $i% "$tdir/$img";
    i=$((i-10));
  done

  echo "Fade";
}

###############################################################################

function effect_overlay() {
  local tdir="$1";
  local n=`ls $dir | grep '^GOLS_3_[0-9]*.png$' | wc -l`;

  local i=0;
  for img in `ls $tdir | grep '^GOLS_3_[0-9]*.png$'`; do
    i=$((i+1));
    printf '\rOverlaying %010d/%d' $i $n
    composite \( "$tdir/$ORIG" -resize 20% \)  -gravity SouthWest "$tdir/$img" "$tmpf/$img";
  done
  echo "";
  #composite \( GOLS_0_ORIG.png -resize 20% \) -gravity SouthWest GOLS_3_0000000000.png test.png

  echo "Overlay";
}

###############################################################################

function effect_multiply() {
  local tdir="$1";
  local n=`ls $dir | grep '^GOLS_3_[0-9]*.png$' | wc -l`;

  for img in `ls $tdir | grep '^GOLS_3_[0-9]*.png$'`; do
    composite "$tdir/$ORIG" -compose Multiply "$tdir/$img" "$tmpf/$img";
  done

  #composite GOLS_0_ORIG.png -compose Multiply GOLS_3_0000000000.png test.png
  echo "Multiply";
}

###############################################################################

function effect_reset() {
  local tdir="$1";
  local n=`ls $dir | grep '^GOLS_3_[0-9]*.png$' | wc -l`;

  for img in `ls $tdir/$CLN_SEQ | grep '^GOLS_[0-3]_[0-9]*.png$'`; do
    rm $tdir/$img &> /dev/null
    cp "$tdir/$CLN_SEQ/$img" $tdir;
  done
  echo "Reset";
}

###############################################################################

