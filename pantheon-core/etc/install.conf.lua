return {
  raisin = {
    user = "hugeblank",
    name = "raisin",
    target = "/lib/",
    include = {
      "raisin.lua"
    }
  },
  libproc = {
    user = "pantheonos",
    name = "libproc",
    target = "/lib/",
    include = {
      "lua$",
      "libproc"
    },
    exclude = {
      "moon$"
    },
    dependencies = {
      "raisin"
    }
  },
  procd = {
    user = "pantheonos",
    name = "libproc",
    target = "/bin/",
    include = {
      "procd.lua"
    },
    dependencies = {
      "libproc"
    }
  }
}
