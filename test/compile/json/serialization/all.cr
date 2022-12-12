require "json"
# json/serialization.cr:1 (001)
# EXAMPLE_SEQ=1
# json/serialization.cr:1
# require "json"

class A
  include JSON::Serializable

  @[JSON::Field(key: "my_key", emit_null: true)]
  getter a : Int32?
end
# json/serialization.cr:12 (002)
# EXAMPLE_SEQ=2
module M__Serialization12
# json/serialization.cr:12
# require "json"

struct A
  include JSON::Serializable
  @a : Int32
  @b : Float64 = 1.0
end

A.from_json(%<{"a":1}>) # => A(@a=1, @b=1.0)
# json/serialization.cr:24 (003)
# EXAMPLE_SEQ=3
module M__Serialization24
# json/serialization.cr:24
# require "json"

struct A
  include JSON::Serializable
  include JSON::Serializable::Unmapped
  @a : Int32
end

a = A.from_json(%({"a":1,"b":2})) # => A(@json_unmapped={"b" => 2_i64}, @a=1)
a.to_json                         # => {"a":1,"b":2}
# json/serialization.cr:37 (004)
# EXAMPLE_SEQ=4
# json/serialization.cr:37
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

Shape.from_json(%({"type": "point", "x": 1, "y": 2}))               # => #<Point:0x10373ae20 @type="point", @x=1, @y=2>
Shape.from_json(%({"type": "circle", "x": 1, "y": 2, "radius": 3})) # => #<Circle:0x106a4cea0 @type="circle", @x=1, @y=2, @radius=3>
end # M__Serialization12
end # M__Serialization24
