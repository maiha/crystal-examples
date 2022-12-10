# time.cr
require "spec"
require "../helper"
# time.cr:1 (001)
# EXAMPLE_SEQ=1
( Time.parse_rfc3339("2016-02-15T04:35:50Z") ).should eq( __time__("2016-02-15 04:35:50.0 UTC") )
puts "TEST_PASSED_SEQ=1" # :nocode:

