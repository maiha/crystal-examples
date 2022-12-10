require "json"
require "uuid"
require "uuid/json"
# uuid/json.cr:1 (001)
# EXAMPLE_SEQ=1
# uuid/json.cr:1
# require "json"
# require "uuid"
# require "uuid/json"

class Example
  include JSON::Serializable

  property id : UUID
end

example = Example.from_json(%({"id": "ba714f86-cac6-42c7-8956-bcf5105e1b81"}))
example.id # => UUID(ba714f86-cac6-42c7-8956-bcf5105e1b81)
