#!/bin/sh
rm ../../../assets/game.zip > /dev/null
zip -r ../../../assets/game.zip  Lua Levels Bitmap CorsixTH.lua -x Bitmap/mainmenu1080.bmp Bitmap/*.lua Bitmap/readme.txt
