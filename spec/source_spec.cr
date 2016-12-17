require "./spec_helper"

private def sha1(str, debug = nil)
  Data::Source.sha1(str, debug: debug)
end

describe Data::Source do
  describe ".sha1" do
    it "ignore spaces" do
      sha1("1\n2").should eq(sha1("\n1\n\n2\n\n"))
    end

    it "ignore require" do
      code1 = <<-EOF
        require "foo"
        1
        EOF
      sha1(code1).should eq(sha1("1"))
    end

    it "ignore :nocode:" do
      code1 = <<-EOF
        foo # :nocode:
        1
        EOF
      sha1(code1).should eq(sha1("1"))
    end

    it "works" do
      code1 = <<-EOF
        require "spec"

        it "array.cr" do
        puts # :nocode:
        end # done
        EOF

      code2 = <<-EOF
        it "array.cr" do
        end
        EOF
      
      io = IO::Memory.new
      sha1(code1, debug: io)
      String.new(io.to_slice).should eq(code2)
    end
  end
end
