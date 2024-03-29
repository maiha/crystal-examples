# lib
require "colorize"
require "file_utils"
require "digest/sha1"

# shards
require "try"
require "cmds"
require "shard"
require "shell"
require "sqlite3"
require "comment-spec"
require "toml-config"
require "pon"
require "pon/adapter/sqlite"
require "kemal"
require "kilt/slang"
require "crustache"

# patch
require "./ext/**"

# app
require "./models/**"           # uses data
require "./data/**"
require "./job/**"              # uses models
require "./web"                 # uees models
require "./cli"                 # uses web, generator
