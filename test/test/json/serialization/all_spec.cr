# json/serialization.cr
require "spec"
require "../../helper"
require "json"
# json/serialization.cr:1 (001)
# EXAMPLE_SEQ=1
# require "json"

struct A
  include JSON::Serializable
  @a : Int32
  @b : Float64 = 1.0
end

( A.from_json(%<{"a":1}>) ).should eq( A(@a=1, @b=1.0) )
puts "TEST_PASSED_SEQ=1" # :nocode:

# json/serialization.cr:13 (002)
# EXAMPLE_SEQ=2
module M__Serialization13
# require "json"

class A
  include JSON::Serializable

  @[JSON::Field(key: "my_key", emit_null: true)]
  getter a : Int32?
end
puts "TEST_PASSED_SEQ=2" # :nocode:

# json/serialization.cr:24 (003)
# EXAMPLE_SEQ=3
# require "json"

abstract class Shape
  include JSON::Serializable

  use_json_discriminator "type", {point: Point, circle: Circle}

  property type : String
end

class Point < Shape
  property x : Int32
  property y : Int32
end

class Circle < Shape
  property x : Int32
  property y : Int32
  property radius : Int32
end

( Shape.from_json(%({"type": "point", "x": 1, "y": 2})) ).class.to_s.gsub(/^(M__.*?::)+/,"").should eq( "Point" )
( Shape.from_json(%({"type": "circle", "x": 1, "y": 2, "radius": 3})) ).class.to_s.gsub(/^(M__.*?::)+/,"").should eq( "Circle" )
puts "TEST_PASSED_SEQ=3" # :nocode:

end # M__Serialization13
