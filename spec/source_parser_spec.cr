require "./spec_helper"

private def parse(code)
  Data::SourceParser.parse("test.cr", Data::Source.new("(test)"), IO::Memory.new(code))
end

describe Data::SourceParser do
  describe ".parse" do
    it "builds comments" do
      source = parse <<-EOF
        # ```
        # Array(Int32).new  # => []
        # ```
        ...
        # ```crystal
        # [] of Int32 # same as Array(Int32)
        # ```
        EOF
      source.comments.size.should eq(2)
      source.comments.map(&.type).should eq(["", "crystal"])
      source.error?.should eq(nil)
    end

    it "fails when unspected end" do
      source = parse <<-EOF
        # ```
        # Array(Int32).new  # => []
        # ```
        ...
        # ```
        # a = [1]
        # a.pop { "Testing" } #=> 1
        def pop
        end
        EOF
      source.comments.size.should eq(1)
      source.error?.should match(/unexpected example end/)
    end
  end
end
