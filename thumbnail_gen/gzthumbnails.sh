#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ASSETS="$(pwd)"

for dir in $ASSETS/*/
do
  dir=${dir%*/}
  echo "Creating thumbnail for ${dir##*/}"
  rm -rf $ASSETS/${dir##*/}/thumbnails
  if [[ -f $ASSETS/${dir##*/}/model.sdf ]]; then
    # generate thumbnails with green bg
    gzserver -s libModelPropShop.so $DIR/green.world --propshop-save "$ASSETS/${dir##*/}/thumbnails" --propshop-model "$ASSETS/${dir##*/}/model.sdf"
    for file in $ASSETS/${dir##*/}/thumbnails/*
    do
      # make green bg transparent
      color="#00ff00"
      convert $file -alpha off -bordercolor $color -border 1 \
        \( +clone -fuzz 30% -fill none -floodfill +0+0 $color \
          -alpha extract -geometry 200% -blur 0x0.5 \
          -morphology erode square:1 -geometry 50% \) \
        -compose CopyOpacity -composite -shave 1 $file
      convert $file -fuzz 30% -transparent $color $file
      # add shadow
      convert $file \( -clone 0 -background black -shadow 100x10+0+0 \) -reverse -background none -layers merge +repage $file
      # crop transparent ends
      convert $file -trim $file
      done
  fi
done