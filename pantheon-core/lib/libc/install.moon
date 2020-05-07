-- libc.install
-- Installers for Pantheon
-- By daelvn
import clone, verify, remove from require "libgit.clone"
echo = kdprint "install"

-- load config
config   = loadConfig "install"
config or= {}

-- unpacks a source
fromSource ==> @user, @name, @branch, @target, @include, @exclude, @timeout

-- installs a source
install = (source) ->
  src = config[source]
  -- check that the source exists and is not already installed
  return false, "Source does not exist" unless src
  return true, "Source is already installed" if verify fromSource src
  -- install dependencies
  if src.dependencies
    install dep for dep in *src.dependencies
  -- clone repo
  echo "Installing #{source}"
  ok, err = clone fromSource src
  return false, err unless ok
  -- run post install script
  if src.postInstall
    src.postInstall!
  --
  return true

-- uninstalls a source
uninstall = (source) ->
  src = config[source]
  -- check that the source exists and is already installed
  return false, "Source does not exist" unless src
  return true, "Source is already uninstalled" unless verify fromSource src
  -- remove repo
  echo "Uninstalling #{source}"
  return remove fromSource src
 
{
  :install, :uninstall
}