-- pantheon/pd
-- Peripheral Daemon
-- Wraps peripherals on connect and destroys them on deattach
import Peripheral from require "libperiph"

-- List of wrapped peripherals
export devices = {}

-- Capitalizes the first letter of a name
firstUpper = (str) -> str\gsub "^%l", string.upper

-- Main loop
while true do
  evt, evt1 = os.pullEventRaw!
  switch evt
    when "peripheral"
      periph                 = Peripheral evt1
      PA_PRINT "attaching #{periph.kind}"
      devices[periph.kind] or= {}
      table.insert devices[periph.kind], periph
    when "peripheral_detach"
      broken = false
      for kind, devl in pairs devices
        for i, dev in ipairs devl
          if dev.id == evt1
            table.remove devices[kind], i
            broken = true
            break
        break if broken
    else continue

