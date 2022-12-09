# json/to_json.cr
require "spec"
require "../../helper"
require "json"
# json/to_json.cr:4 (001)
# EXAMPLE_SEQ=1
# #<Models::Heuristic id: 243, action: "test", target: "53d5f3e0892dd941437afd9b808ec52f6d8eb6df", by: "random", comment: "json/to_json.cr:185:20201011">
# # require "json"
# 
# class TimestampArray
#   include JSON::Serializable
# 
#   @[JSON::Field(converter: JSON::ArrayConverter(Time::EpochConverter))]
#   property dates : Array(Time)
# end
# 
# timestamp = TimestampArray.from_json(%({"dates":[1459859781,1567628762]}))
# ( timestamp.dates ).should eq( [2016-04-05 12:36:21 UTC, 2019-09-04 20:26:02 UTC] )
# ( timestamp.to_json ).should eq( %({"dates":[1459859781,1567628762]}) )

# json/to_json.cr:22 (002)
# EXAMPLE_SEQ=2
# require "json"

class TimestampArray
  include JSON::Serializable

  @[JSON::Field(converter: JSON::ArrayConverter.new(Time::Format.new("%b %-d, %Y")))]
  property dates : Array(Time)
end

timestamp = TimestampArray.from_json(%({"dates":["Apr 5, 2016","Sep 4, 2019"]}))
( timestamp.dates ).should eq( [2016-04-05 00:00:00 UTC, 2019-09-04 00:00:00 UTC] )
( timestamp.to_json ).should eq( %({"dates":["Apr 5, 2016","Sep 4, 2019"]}) )
puts "TEST_PASSED_SEQ=2" # :nocode:

