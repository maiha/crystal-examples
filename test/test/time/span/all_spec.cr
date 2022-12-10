# time/span.cr
require "spec"
require "../../helper"
# time/span.cr:1 (001)
# EXAMPLE_SEQ=1
( Time::Span.new(nanoseconds: 10_000) ).should eq( Time::Span.new(days: 0, hours: 0, minutes: 0, seconds: 0, nanoseconds: 10000) )
( Time::Span.new(hours: 10, minutes: 10, seconds: 10) ).should eq( Time::Span.new(days: 0, hours: 10, minutes: 10, seconds: 10) )
( Time::Span.new(days: 10, hours: 10, minutes: 10, seconds: 10) ).should eq( Time::Span.new(days: 10, hours: 10, minutes: 10, seconds: 10) )
puts "TEST_PASSED_SEQ=1" # :nocode:

