import loadFont from require "libfont"
import colors   from require "libcolor"
font_CraftOS, err = loadFont "/etc/fonts/CraftOS-Normal-9.font.lua"
echo              = kdprint "vrh-example"

echo "starting up..."
echo "setting graphics mode = 2"
term.setGraphicsMode 2

phrase = {"H", "e", "l", "l", "o", "!"}
xoff   = 1
yoff   = 1
for char in *phrase
  bmp = font_CraftOS.characters[char]
  echo "dumping bitmap for #{char}"
  kdump inspect bmp
  kbreak!
  for x=1, 6
    for y=1, 9
      if bmp[x][y]
        term.setPixel x+xoff, y+yoff, 5
  xoff += 7

PA_BREAK!