class Data::SourceParser
  def self.parse(path : String) : Source
    name   = Source.relative(path)
    source = Source.new(name)
    parse(name, source, File.open(path))
  end

  # split IO for test
  def self.parse(path : String, source : Source, io : IO) : Source
    line_no = 0
    current : Comment? = nil
    while (line = io.gets)
      line_no += 1
      case line
      when /^\s*#\s*```(.*?)$/
        if current
          source.comments << current
          current = nil
        else
          current = Comment.new(path, line_no, $1)
        end
      when /^\s*# ?(.*?)$/
        current.try(&.<< $1)
      else
        if current
          raise Errors::UnexpectedEnd.new(path, line_no, line, current, source.comments)
        end
      end
    end
    return source
  rescue err
    source.error = err.to_s
    return source
  end
end
