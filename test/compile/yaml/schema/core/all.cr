# [heuristic:161] require yaml/schema/core.cr by:yaml/schema/core comment:yaml/schema/core.cr:1:20180101
require "yaml/schema/core"
require "yaml"
# yaml/schema/core.cr:1 (001)
# EXAMPLE_SEQ=1
# yaml/schema/core.cr:1
# require "yaml"

YAML::Schema::Core.parse_scalar("hello") # => "hello"
YAML::Schema::Core.parse_scalar("1.2")   # => 1.2
YAML::Schema::Core.parse_scalar("false") # => false
