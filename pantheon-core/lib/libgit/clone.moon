-- pantheon/libgit.clone
-- Clones GitHub repos
-- By daelvn
import contentFor, GET from require "libhttp.api"
import writeTo         from require "libc.io"
echo         = kdprint "libgit.clone"
nap          = require "libhttp.nap"

-- load config
config          = loadConfig "libgit"
config        or= {}
config.url    or= "https://api.github.com/"
config.rawurl or= "https://raw.github.com/"

-- get api endpoints
github      = nap config.url
githubRaw   = nap config.rawurl
getEndpoint = contentFor json: true
getFile     = contentFor json: false

-- gets files and folders
getff = (user, name, branch="master", target="/", include={}, exclude={}) ->
  expect 1, user,    {"string"}
  expect 2, name,    {"string"}
  expect 3, branch,  {"string"}
  expect 4, target,  {"string"}
  expect 5, include, {"table"}
  expect 6, exclude, {"table"}
  --
  tree = getEndpoint github.repos[user][name].git.trees[branch] GET query: recursive: 1
  --echo inspect tree.tree
  files, folders = {}, {}
  -- split into files and folders
  for node in *tree.tree
    break unless node
    -- sort into folders or files
    if node.type == "blob"
      table.insert files, node
    elseif node.type == "tree"
      table.insert folders, node
  -- check include rules
  nfl, nfs = {}, {}
  for pat in *include
    selfl = [nd for nd in *files   when nd.path\match pat]
    selfs = [nd for nd in *folders when nd.path\match pat]
    table.insert nfl, nd for nd in *selfl
    table.insert nfs, nd for nd in *selfs
  if #include > 0
    files, folders = nfl, nfs
  -- check exclude rules
  nfl, nfs = {}, {}
  for pat in *exclude
    selfl = [nd for nd in *files   when not nd.path\match pat]
    selfs = [nd for nd in *folders when not nd.path\match pat]  
    table.insert nfl, nd for nd in *selfl
    table.insert nfs, nd for nd in *selfs
  if #exclude > 0
    files, folders = nfl, nfs
  -- undupe entries
  files   = table.undupe files
  folders = table.undupe folders
  -- return
  return files, folders

-- clones a github repo
clone = (user, name, branch="master", target="/", include={}, exclude={}, timeout=30) ->
  expect 7, timeout, {"number"}
  echo "Cloning: #{user}/#{name}"
  files, folders = getff user, name, branch, target, include, exclude
  -- create all folders
  for folder in *folders
    fs.makeDir fs.combine target, folder.path
  -- queue files
  waitfor, urlassoc = {}, {}
  for file in *files
    thisurl           = "#{config.rawurl}#{user}/#{name}/#{branch}/#{file.path}"
    urlassoc[thisurl] = fs.combine target, file.path
    table.insert waitfor, thisurl
    githubRaw[user][name][branch][file.path] GET {async: true}
  -- download files
  etime = os.timer timeout
  while true
    evt, eurl, ehan, e3 = os.pullEvent!
    if (evt == "timer") and (eurl == etime)
      return false, "Timeout reached"
    continue unless table.contains waitfor, eurl
    if evt == "http_success"
      echo "Got: #{urlassoc[eurl]}"
      writeTo urlassoc[eurl], ehan\readAll!
      urlassoc[eurl] = nil
      ehan\close!
    elseif evt == "http_failure"
      echo "Retrying: #{urlassoc[eurl]}"
      githubRaw[user][name][branch][urlassoc[eurl]] GET {async: true}
    break if 0 == table.getn urlassoc
  --
  return true

-- Verifies that something was installed
verify = (user, name, branch="master", target="/", include={}, exclude={}) ->
  echo "Verifying: #{user}/#{name}"
  files, folders = getff user, name, branch, target, include, exclude
  -- check all folders
  for folder in *folders
    unless fs.exists fs.combine target, folder.path
      return false, "Folder #{folder.path} does not exist"
  -- check all files
  for file in *files
    unless fs.exists fs.combine target, file.path
      return false, "File #{file.path} does not exist"
  --
  return true

-- removes a gh repo
removes = (user, name, branch="master", target="/", include={}, exclude={}, timeout=30) ->
  echo "Removing: #{user}/#{name}"
  files, folders = getff user, name, branch, target, include, exclude
  -- check all folders
  for folder in *folders
    unless fs.exists fs.combine target, folder.path
      return false, "Folder #{folder.path} does not exist"
    fs.delete fs.combine target, folder.path
  -- check all files
  -- for file in *files
  --   return false unless fs.exists fs.combine target, file.path
  --   fs.combine target, folder.path
  --
  return true

--clone "daelvn", "grasp", nil, "/lib/", {"lua$", "^grasp"}, {"moon$"}

{
  :clone, :verify, :remove
}