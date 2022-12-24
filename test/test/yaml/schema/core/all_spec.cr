# yaml/schema/core.cr
require "spec"
require "../../../helper"
# [heuristic:163] require yaml/schema/core.cr by:yaml/schema/core comment:yaml/schema/core.cr:1:20180101
require "yaml/schema/core"
require "yaml"
# yaml/schema/core.cr:1 (001)
# EXAMPLE_SEQ=1
# require "yaml"

( YAML::Schema::Core.parse_scalar("hello") ).to_s.should eq( "hello" )
( YAML::Schema::Core.parse_scalar("1.2") ).to_s.should eq( "1.2" )
( YAML::Schema::Core.parse_scalar("false") ).should eq( false )
puts "TEST_PASSED_SEQ=1" # :nocode:

