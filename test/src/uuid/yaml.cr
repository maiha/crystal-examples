  # ```
  # require "yaml"
  # require "uuid"
  # require "uuid/yaml"
  #
  # class Example
  #   include YAML::Serializable
  #
  #   property id : UUID
  # end
  #
  # example = Example.from_yaml("id: 50a11da6-377b-4bdf-b9f0-076f9db61c93")
  # example.id # => UUID(50a11da6-377b-4bdf-b9f0-076f9db61c93)
  # ```
