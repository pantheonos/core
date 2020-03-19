# pantheon/libperiph

Peripheral management with Pantheon.

## Using libperiph

libperiph is based around the idea of not using sides to get peripherals, removing the physical concept from it. You're still free to wrap a side on your own using `Peripheral`, but the preferred way of going is:

```lua
myModem = peripheral(find "modem")
```

### Basics

So, say you have a printer conected over wired modem, and we want to print a single message on a single page. In normal CC, you'd do:

```moon
printer = peripheral.find "printer"
printer.newPage!
printer.write "hello, world!"
printer.endPage!
```

Which is simple enough, honestly. Using libperiph, you would do:

```moon
import peripheral, find from require "libperiph"
printer = peripheral find "printer"

import newPage, write, endPage from
  {name, method printer for name, method in pairs printer.methods}
-- these imported function work on ALL printers attached via libperiph
-- and all the table comprehension is doing is applying the printer argument.
-- we wouldn't do this if we were dealing with more printers

newPage!
write "hello, world!"
endPage!
```