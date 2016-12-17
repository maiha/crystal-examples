class Data::Comment
  property path
  property line
  property type
  property lines

  def initialize(@path : String, @line : Int32, @type : String)
    @lines = Array(String).new
  end

  def <<(line : String)
    @lines << line
  end

  def crystal?
    @type == "" || @type == "crystal"
  end

  def require_code? : String?
    (@lines[0] =~ /require/) ? @lines[0] : nil
  end

  def source
    String.build do |io|
      io << "  # ```#{@type}\n"
      lines.each do |line|
        io << "  ##{line}\n"
      end
    end
  end

  def code
    lines.join("\n")
  end
end
