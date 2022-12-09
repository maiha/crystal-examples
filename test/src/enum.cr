# Enum is the base type of all enums.
#
# An enum is a set of integer values, where each value has an associated name. For example:
#
# ```
# enum Color
#   Red   # 0
#   Green # 1
#   Blue  # 2
# end
# ```
#
# Values start with the value `0` and are incremented by one, but can be overwritten.
#
# To get the underlying value you invoke value on it:
#
# ```
# Color::Green.value # => 1
# ```
#
# Each constant (member) in the enum has the type of the enum:
#
# ```
# typeof(Color::Red) # => Color
# ```
#
# ### Flags enum
#
# An enum can be marked with the `@[Flags]` annotation. This changes the default values:
#
# ```
# @[Flags]
# enum IOMode
#   Read  # 1
#   Write # 2
#   Async # 4
# end
# ```
#
# Additionally, some methods change their behaviour.
#
# ### Enums from integers
#
# An enum can be created from an integer:
#
# ```
# Color.new(1).to_s # => "Green"
# ```
#
# Values that don't correspond to enum's constants are allowed: the value
# will still be of type Color, but when printed you will get the underlying value:
#
# ```
# Color.new(10).to_s # => "10"
# ```
#
# This method is mainly intended to convert integers from C to enums in Crystal.
#
# ### Question methods
#
# An enum automatically defines question methods for each member, using
# `String#underscore` for the method name.
# * In the case of regular enums, this compares by equality (`==`).
# * In the case of flags enums, this invokes `includes?`.
#
# For example:
#
# ```
# color = Color::Blue
# color.red?  # => false
# color.blue? # => true
#
# mode = IOMode::Read | IOMode::Async
# mode.read?  # => true
# mode.write? # => false
# mode.async? # => true
# ```
#
# This is very convenient in `case` expressions:
#
# ```
# case color
# when .red?
#   puts "Got red"
# when .blue?
#   puts "Got blue"
# end
# ```
#
# ### Changing the Base Type
#
# The type of the underlying enum value is `Int32` by default, but it can be changed to any type in `Int::Primitive`.
#
# ```
# enum Color : UInt8
#   Red
#   Green
#   Blue
# end
#
# Color::Red.value # : UInt8
# ```
struct Enum
  include Comparable(self)

  # Returns *value*.
  def self.new(value : self)
    value
  end

  # Returns the underlying value held by the enum instance.
  #
  # ```
  # enum Color
  #   Red
  #   Green
  #   Blue
  # end
  #
  # Color::Red.value   # => 0
  # Color::Green.value # => 1
  # Color::Blue.value  # => 2
  # ```
  def value : Int
    previous_def
  end
  # Returns a `String` representation of this enum member.
  # In the case of regular enums, this is just the name of the member.
  # In the case of flag enums, it's the names joined by vertical bars, or "None",
  # if the value is zero.
  #
  # If an enum's value doesn't match a member's value, the raw value
  # is returned as a string.
  #
  # ```
  # Color::Red.to_s                     # => "Red"
  # IOMode::None.to_s                   # => "None"
  # (IOMode::Read | IOMode::Write).to_s # => "Read | Write"
  #
  # Color.new(10).to_s # => "10"
  # ```
end
