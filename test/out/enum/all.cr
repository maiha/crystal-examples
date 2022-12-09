# src/enum.cr:5 (001)
# EXAMPLE_SEQ=1
# src/enum.cr:5
enum Color
  Red   # 0
  Green # 1
  Blue  # 2
end
# src/enum.cr:17 (002)
# EXAMPLE_SEQ=2
# src/enum.cr:17
Color::Green.value # => 1
# src/enum.cr:23 (003)
# EXAMPLE_SEQ=3
# src/enum.cr:23
typeof(Color::Red) # => Color
# src/enum.cr:31 (004)
# EXAMPLE_SEQ=4
# src/enum.cr:31
@[Flags]
enum IOMode
  Read  # 1
  Write # 2
  Async # 4
end
# src/enum.cr:46 (005)
# EXAMPLE_SEQ=5
# src/enum.cr:46
Color.new(1).to_s # => "Green"
# src/enum.cr:53 (006)
# EXAMPLE_SEQ=6
# src/enum.cr:53
Color.new(10).to_s # => "10"
# src/enum.cr:68 (007)
# EXAMPLE_SEQ=7
# src/enum.cr:68
color = Color::Blue
color.red?  # => false
color.blue? # => true

mode = IOMode::Read | IOMode::Async
mode.read?  # => true
mode.write? # => false
mode.async? # => true
# src/enum.cr:81 (008)
# EXAMPLE_SEQ=8
# src/enum.cr:81
case color
when .red?
  puts "Got red"
when .blue?
  puts "Got blue"
end
# src/enum.cr:94 (009)
# EXAMPLE_SEQ=9
# src/enum.cr:94
enum Color : UInt8
  Red
  Green
  Blue
end

Color::Red.value # : UInt8
# src/enum.cr:113 (010)
# EXAMPLE_SEQ=10
# src/enum.cr:113
enum Color
  Red
  Green
  Blue
end

Color::Red.value   # => 0
Color::Green.value # => 1
Color::Blue.value  # => 2
# src/enum.cr:135 (011)
# EXAMPLE_SEQ=11
# src/enum.cr:135
Color::Red.to_s                     # => "Red"
IOMode::None.to_s                   # => "None"
(IOMode::Read | IOMode::Write).to_s # => "Read | Write"

Color.new(10).to_s # => "10"
