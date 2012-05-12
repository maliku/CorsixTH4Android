#!/bin/sh
rm ../../../assets/game.zip > /dev/null
zip -r ../../../assets/game.zip  Lua Levels Bitmap CorsixTH.lua -x Bitmap/top_panel/* Bitmap/*.bmp Bitmap/*.spec Bitmap/*.lua Bitmap/readme.txt Bitmap/*.png
