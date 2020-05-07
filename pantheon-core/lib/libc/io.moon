-- pantheon/libc.io
-- IO utilities
-- By daelvn

tempFilename = (prefix="/tmp/", suffix=".txt") ->
  expect 1, prefix, {"string"}, "tempFilename"
  expect 2, suffix, {"string"}, "tempFilename"
  math.randomseed os.epoch "utc"
  filename = ""
  for i=1, 5
    randchar = string.char math.random 65, 122
    while randchar\match "[%[\\%]%^%_%`]"
      randchar = string.char math.random 65, 122
    filename ..= randchar
  return "#{prefix}#{filename}#{suffix}"

writeTo = (filename, text) ->
  expect 1, filename, {"string"}, "writeTo"
  expect 1, text,     {"string"}, "writeTo"
  with fs.open filename, "w"
    .write text
    .close!

-- Let's implement a simple read function
fread = (n=-1) ->
  return if n == 0
  final = ""
  while true
    evt, echar = os.pullEvent "char"
    final ..= echar
    n      -= 1
    break if n == 0
  final


{
  :tempFilename, :writeTo, :fread
}