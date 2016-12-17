# Examples extractor for one source file
class Job::Extract
  include Data
  
  var skip_error   = false
  var records      = Array(Pon::Persistence).new
  var heuristics   = Heuristics.new

  def initialize(@relative : String, @comments : Array(Comment))
    @dir  = File.dirname(@relative)         # "http"
    @name = File.basename(@relative, ".cr") # "client"
  end

  def run : Array(Pon::Persistence)
    @comments.each_with_index do |c, i|
      records << build_example(c, i) # next model
      records << build_spec(c, i)
    end
    return records
  end

  private def build_example(c : Comment, i) : Pon::Persistence
    Models::Example.new(src: @relative, seq: i+1, line: c.line, type: c.type, code: c.code)
  end
  
  private def build_spec(c : Comment, i) : Pon::Persistence
    code = c.lines.map{|line| CommentSpec.parse(line)}.join("\n")
    Models::Spec.new(path: @relative, seq: i+1, line: c.line, code: c.code)
  end
end
