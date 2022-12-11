# enum.cr
require "spec"
require "../helper"
# enum.cr:5 (001)
# EXAMPLE_SEQ=1
enum Color
  Red   # 0
  Green # 1
  Blue  # 2
end
puts "TEST_PASSED_SEQ=1" # :nocode:

# enum.cr:17 (002)
# EXAMPLE_SEQ=2
( Color::Green.value ).should eq( 1 )
puts "TEST_PASSED_SEQ=2" # :nocode:

# enum.cr:23 (003)
# EXAMPLE_SEQ=3
( typeof(Color::Red) ).should eq( Color )
puts "TEST_PASSED_SEQ=3" # :nocode:

# enum.cr:31 (004)
# EXAMPLE_SEQ=4
@[Flags]
enum IOMode
  Read  # 1
  Write # 2
  Async # 4
end
puts "TEST_PASSED_SEQ=4" # :nocode:

# enum.cr:46 (005)
# EXAMPLE_SEQ=5
( Color.new(1).to_s ).to_s.should eq( "Green" )
puts "TEST_PASSED_SEQ=5" # :nocode:

# enum.cr:53 (006)
# EXAMPLE_SEQ=6
( Color.new(10).to_s ).to_s.should eq( "10" )
puts "TEST_PASSED_SEQ=6" # :nocode:

# enum.cr:68 (007)
# EXAMPLE_SEQ=7
color = Color::Blue
( color.red? ).should eq( false )
( color.blue? ).should eq( true )

mode = IOMode::Read | IOMode::Async
( mode.read? ).should eq( true )
( mode.write? ).should eq( false )
( mode.async? ).should eq( true )
puts "TEST_PASSED_SEQ=7" # :nocode:

# enum.cr:81 (008)
# EXAMPLE_SEQ=8
case color
when .red?
  puts "Got red"
when .blue?
  puts "Got blue"
end
puts "TEST_PASSED_SEQ=8" # :nocode:

# enum.cr:94 (009)
# EXAMPLE_SEQ=9
module M__Enum94
enum Color : UInt8
  Red
  Green
  Blue
end

Color::Red.value # : UInt8
puts "TEST_PASSED_SEQ=9" # :nocode:

# enum.cr:113 (010)
# EXAMPLE_SEQ=10
module M__Enum113
enum Color
  Red
  Green
  Blue
end

( Color::Red.value ).should eq( 0 )
( Color::Green.value ).should eq( 1 )
( Color::Blue.value ).should eq( 2 )
puts "TEST_PASSED_SEQ=10" # :nocode:

# enum.cr:135 (011)
# EXAMPLE_SEQ=11
( Color::Red.to_s ).to_s.should eq( "Red" )
( IOMode::None.to_s ).to_s.should eq( "None" )
( (IOMode::Read | IOMode::Write).to_s ).to_s.should eq( "Read | Write" )

( Color.new(10).to_s ).to_s.should eq( "10" )
puts "TEST_PASSED_SEQ=11" # :nocode:

end # M__Enum94
end # M__Enum113
