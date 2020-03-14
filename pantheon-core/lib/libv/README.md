# pantheon/libv

LibV is the core of the V Window Sever and rendering server.

## Concepts

Components marked with an asterisk are only available without Graphics Mode.

### Pixel

A pixel represents the atomic modifiable unit of libv. Depending on your platform, these pixels will be able to carry a character or not. libv will automatically try to detect your platform, and set the graphics mode to the highest possible. Every pixel has a position starting from `1,1`

- Color
- Foreground color\*
- Character\*

### Buffer

A buffer is a 2D array of pixels of any given size. The position of the Buffer is determined by its top left corner, relative to `1,1`. The position can also be negative.

- Movable
- Resizable
- Writable

### Group

An ordered group of several buffers or subgroups that allows them to move, hide and show together.

### Frame

A frame is a special kind of object that contains a size that must be smaller or equal to the size of the screen, and a *framebuffer*. The frame is "placed" over the layered buffers, which then merges all pixel information into the framebuffer. This is the only buffer that actually gets rendered onto the screen.