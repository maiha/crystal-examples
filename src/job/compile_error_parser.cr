class Job::CompileErrorParser
  alias Seqs  = Range(Int32, Int32)
  alias Error = Models::CompileCache::Error

  FIND_SEQ = /^#{Generate::SEQ_MARK}(\d+)/
  NO_SEQ   = -1

  var error_type       : Error = Error::NOT_FOUND
  var error_value      : String = ""
  var try_line_number  : Try(Int32) = parse_line_number
  var try_error_seq    : Try(Int32) = parse_error_seq
  var try_success_seqs : Try(Seqs)  = parse_success_seqs
  var src_buffer       : String
  
  def initialize(@buf : String, src : String? = nil)
    self.src_buffer = src
    parse
  end
  
  def parse : Try(Seqs)
    try_success_seqs
  end
  
  def line_number? : Int32?
    try_line_number.get?
  end
  
  def line_number : Int32
    try_line_number.get
  end
  
  def error_seq? : Int32?
    try_error_seq.get?
  end
  
  def error_seq : Int32
    try_error_seq.get
  end
  
  def success_seqs? : Seqs?
    try_success_seqs.get?
  end
  
  def success_seqs : Seqs
    try_success_seqs.get
  end
  
  private def parse_line_number : Try(Int32) # should be "n > 0"
    Try(Int32).try {
      # I hope the hint should exist within first 10 lines.
      heads = @buf.strip.split(/\n/).first(10)
      while head = heads.shift?
        case head
        when /Using compiled compiler/
        when /^% /
        else
          heads.unshift head
          break
        end
      end
      
      case heads.join("\n")
      when /^Syntax error in [^\.]+\.cr:(\d+): /i
        #   "Syntax error in tmp/http/client/all.cr:127: expecting"
        self.error_type = Error::SYNTAX_ERROR
        line = $1.to_i
      when /\.cr:(\d+): undefined constant ([A-Za-z0-9]+(::[A-Za-z0-9]+)*)/
        #   "Error in tmp/http/cookie/all.cr:3: undefined constant HTTP::Request"
        self.error_type  = Error::UNDEFINED_CONSTANT
        self.error_value = $2
        line = $1.to_i
      when /\.cr:(\d+): /
        #   "Error in tmp/array/all.cr:36: instantiating"
        self.error_type = Error::UNKNOWN_ERROR
        line = $1.to_i
      end

      if v = line
        v
      else
        sample = heads.first(3).join("\n")
        raise "parse_line_number: can't find lineno from '#{sample}'"
      end
    }
  end
  
  private def parse_error_seq : Try(Int32)
    Try(Int32).try {
      line_number    = try_line_number.get
      max_line_index = [line_number-1, 0].max
      found_seq      = NO_SEQ

      lines = src_buffer.split(/\n/)[0..max_line_index]

      lines.each do |line|
        if line =~ FIND_SEQ
          found_seq = $1.to_i
        end
      end

      if found_seq == NO_SEQ
        raise "no seq marks found. (first line: '#{lines[0]?}', line_number: #{line_number}, mark: '#{FIND_SEQ.source}')"
      elsif found_seq < 1
        raise "BUG: invalid found_seq '#{found_seq}' (line_number=#{line_number})"
      end

      found_seq
    }
  end

  private def parse_success_seqs : Try(Seqs)
    Try(Seqs).try {
      last_success_seq = [0, try_error_seq.get - 1].max
      (1..last_success_seq)
    }
  end
end
