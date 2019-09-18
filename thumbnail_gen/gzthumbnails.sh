#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ASSETS="$(pwd)"

for dir in $ASSETS/*/
do
  dir=${dir%*/}
  if [[ -f $ASSETS/${dir##*/}/model.sdf ]]; then
    if [[ ! -d $ASSETS/${dir##*/}/thumbnails/ ]]; then
      echo "Creating thumbnail for ${dir##*/}"
      # generate thumbnails with solid bg
      gzserver -s libModelPropShop.so $DIR/black.world --propshop-save "$ASSETS/${dir##*/}/thumbnails" --propshop-model "$ASSETS/${dir##*/}/model.sdf"
      for file in $ASSETS/${dir##*/}/thumbnails/*
      do
        # make bg transparent
        color="#000000"
        convert $file -alpha off -bordercolor $color -border 1 \
          \( +clone -fuzz 5% -fill none -floodfill +0+0 $color \
            -alpha extract -geometry 200% -blur 0x0.5 \
            -morphology erode square:1 -geometry 50% \) \
          -compose CopyOpacity -composite -shave 1 $file
        convert $file -fuzz 5% -transparent $color $file
        # add shadow
        convert $file \( -clone 0 -background black -shadow 100x10+0+0 \) -reverse -background none -layers merge +repage $file
        # crop transparent ends
        convert $file -trim $file
      done
    fi
  fi
done