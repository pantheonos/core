-- pantheon/libc.debug
-- Debug globals
-- By daelvn

(dbg) ->
  import writeTo, tempFilename from require "libc.io"
  -- export k* debugging symbols
  export K_LOG   = ""
  export kdump   = -> writeTo "/tmp/init-0.log", K_LOG
  export klog    = (text) ->
    K_LOG ..= (tostring text) .. "\n"
    (dbg.methods.print dbg) text
    kdump!
  export kprint  = klog
  export kdprint = (tag) -> (text) -> klog "#{tag}: #{text}"
  export kbreak  = dbg.methods.stop dbg
  export knewlog = (name, txt, filename=(tempFilename "/tmp/#{fs.getName name}-#{uid}-")) ->
    writeTo filename, txt
  -- expect, using typeof and debug
  export expect = (n, v, ts, fr="") ->
    bios.expect 1, n,  {"number"}
    bios.expect 3, ts, {"table"}
    for ty in *ts
      return true if ty == typeof v
    kprint "#{fr}: bad argument ##{n} (expected #{table.concat ts, ' or '}, got #{type v})", 2
    kbreak!