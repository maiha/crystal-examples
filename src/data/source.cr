class Data::Source
  var path : String
  var comments = Array(Comment).new
  var error : String?

  def initialize(path : String)
    self.path = path
  end
end

class Data::Source
  def self.parse(path)
    SourceParser.parse(path)
  end

  def self.relative(path : String)
    path.sub(/^(.*\/)?src\//, "")
  end

  def self.code(code : String)
    normalized = String.build do |s|
      code.split(/\n+/).each do |line|
        line = line.strip
        case line
        when /^\s*require/, /:nocode:/, /^\s*#/, /^\s*$/
        when /(.*?)#/
          s.puts $1.strip
        else
          s.puts line
        end
      end
    end.strip
  end

  def self.sha1(code : String, debug : IO? = nil)
    normalized = self.code(code)
    debug.print normalized if debug
    Digest::SHA1.hexdigest(normalized)
  end
end
