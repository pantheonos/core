import loadFont from require "libfont"
import PLATFORM from require "libv2.platform"
font_CraftOS, err  = loadFont "/etc/fonts/CraftOS-Normal-9.font.lua"
echo               = kdprint "fontrender"

--# start #--
echo "starting up on platform #{PLATFORM!}"

--# get screen dimensions #--
tw, th = term.getSize!
tw *= 6
th *= 9
echo "screen dimensions (#{tw},#{th})"

--# create new window #--
echo "creating own window"
this = vrh.Window {
  x: 1,  y: 1, d: 1
  w: tw, h: th
}

--# bind window to functions #--
import setPixel from require "libv.buffer"
setPx = setPixel this

--# do the writing #--
echo "perform writing on window"
import Pixel      from require "libv.pixel"
import ColorIndex from require "libcolor2"
phrase = {"H", "e", "l", "l", "o", "!"}
xoff   = 0
yoff   = 0
ci     = ColorIndex 5, true
px     = Pixel ci
for char in *phrase
  bmp = font_CraftOS.characters[char]
  for y=1, 9
    for x=1, 6
      if bmp[y][x]
        setPx x+xoff, y+yoff, px
  xoff += 6

--# render to the screen #--
echo "render window"
vrh.render!

--# halt #--
PA_BREAK!