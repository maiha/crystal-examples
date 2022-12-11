# yaml/schema/core.cr
require "spec"
require "../../../helper"
# [heuristic:168] require yaml/schema/core.cr by:yaml/schema/core comment:yaml/schema/core.cr:1:20180101
require "yaml/schema/core"
require "yaml"
# yaml/schema/core.cr:1 (001)
# EXAMPLE_SEQ=1
# #<Models::Heuristic id: 192, action: "test", target: "12e127d7c925db31f65058662ea942ea918d6579", by: "pending", comment: "yaml/schema/core.cr:58:20190320">
# # require "yaml"
# 
# ( YAML::Schema::Core.parse_scalar("hello") ).to_s.should eq( "hello" )
# ( YAML::Schema::Core.parse_scalar("1.2") ).to_s.should eq( "1.2" )
# ( YAML::Schema::Core.parse_scalar("false") ).should eq( false )

