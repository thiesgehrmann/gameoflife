#!/bin/sh

CLN_SEQ='complete_seq';
EFCTS="fade overlay multiply reset";



function effect_fade() {
  local tdir="$1";
  local n=`ls $dir | grep '^GOLS_3_[0-9]*.png$' | wc -l`;
  echo "Fade";
}

function effect_overlay() {
  local tdir="$1";
  local n=`ls $dir | grep '^GOLS_3_[0-9]*.png$' | wc -l`;
  #composite \( GOLS_0_ORIG.png -resize 20% \) -gravity SouthWest GOLS_3_0000000000.png test.png

  echo "Overlay";
}

function effect_multiply() {
  local tdir="$1";
  local n=`ls $dir | grep '^GOLS_3_[0-9]*.png$' | wc -l`;
  #composite GOLS_0_ORIG.png -compose Multiply SouthWest GOLS_3_0000000000.png test.png
  echo "Multiply";
}

function effect_reset() {
  local tdir="$1";
  local n=`ls $dir | grep '^GOLS_3_[0-9]*.png$' | wc -l`;

  for img in `ls $tdir/$CLN_SEQ | grep '^GOLS_[0-3]_[0-9]*.png$'`; do
    cp "$tdir/$CLN_SEQ/$img" $tdir;
  done
  echo "Reset";
}
