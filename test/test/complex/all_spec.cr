# complex.cr
require "spec"
require "../helper"
# complex.cr:1 (001)
# EXAMPLE_SEQ=1
( Math.sqrt(-1.0) ).try(&.nan?).should be_true
( Math.sqrt(-1.0 + 0.0.i) ).should eq( 0.0 + 1.0.i )
puts "TEST_PASSED_SEQ=1" # :nocode:

