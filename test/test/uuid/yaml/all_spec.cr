# uuid/yaml.cr
require "spec"
require "../../helper"
require "yaml"
require "uuid"
require "uuid/yaml"
# uuid/yaml.cr:1 (001)
# EXAMPLE_SEQ=1
# require "yaml"
# require "uuid"
# require "uuid/yaml"

class Example
  include YAML::Serializable

  property id : UUID
end

example = Example.from_yaml("id: 50a11da6-377b-4bdf-b9f0-076f9db61c93")
( example.id ).should eq( UUID.new("50a11da6-377b-4bdf-b9f0-076f9db61c93") )
puts "TEST_PASSED_SEQ=1" # :nocode:

