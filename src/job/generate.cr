class Job::Generate
  SEQ_MARK = "# EXAMPLE_SEQ="
  TEST_PASSED_SEQ_MARK = "TEST_PASSED_SEQ="

  # src is a relative name of the crystal src like 'array.cr'
  def initialize(@src : String, @examples : Array(Models::Example), @heuristics : Heuristics)
  end

  ######################################################################
  ### code
  
  def code : String
    String.build do |buf|
      if heuristic = @heuristics.requires[@src]?
        buf.puts "# [heuristic:%d] %s" % [heuristic.id, heuristic.to_jnl]
        buf.puts %|require "%s"| % heuristic.by
      end

      @examples.each do |example|
        buf.puts "# %s (%03d)" % [example.clue, example.seq]
        # embeds mark of seq number as comment
        buf.puts (SEQ_MARK + example.seq.to_s)

        code = build_compile_code(example)
        if heuristic = @heuristics.skip_compile[example.sha1]?
          buf.puts "# #{heuristic.to_s}"
          buf.puts code.gsub(/^/m, "# ")
        else
          buf.puts code
        end
      end
    end
  end

  private def build_compile_code(example : Models::Example)
    String.build do |s|
      s.puts "# %s\n" % example.clue
#      s << %|require "#{prelude()}"\n| if prelude && prelude?
      example.codes.each do |line|
        case line
        when /#.*?error/i
          s.puts "# #{line}"
        else
          s.puts line
        end
      end
    end
  end

  ######################################################################
  ### spec

  # Make all examples into one file with `should` statements.
  # Embeds seq number as MARKING STRING into spec code.
  def spec : String
    body = spec_body
    String.build do |s|
      s.puts "# #{@src}"
      s.puts "require \"spec\""
      s.puts prelude
      
      if heuristic = @heuristics.requires[@src]?
        s.puts "# [heuristic:%d] %s" % [heuristic.id, heuristic.to_jnl]
        s.puts %|require "%s"| % heuristic.by
      end
      s.puts require_codes.join("\n")
      if declare_dynamically?
        # TODO: move dynamically declaration into top
        s.puts "# declare_dynamically"
        s.puts body
      else
        s.puts "puts # :nocode:"
        s.puts
        s.puts body
      end
    end
  end

  private def spec_body
    String.build do |buf|
      @examples.each do |example|
        buf.puts "# %s (%03d)" % [example.clue, example.seq]
        # Embeds mark of seq number
        buf.puts (SEQ_MARK + example.seq.to_s)

        code = build_spec_code(example)
        if heuristic = @heuristics.skip_test[example.sha1]? || @heuristics.skip_compile[example.sha1]?
          buf.puts "# #{heuristic.to_s}"
          buf.puts code.gsub(/^/m, "# ")
        else
          buf.puts code
          # Embeds mark of seq number after the spec code has been finished.
          buf.puts(%|puts "#{TEST_PASSED_SEQ_MARK}#{example.seq}" # :nocode:|)
        end
        buf.puts ""
      end
    end
  end

  private def build_spec_code(example : Models::Example)
    example.codes.map{|line| CommentSpec.parse(line)}.join("\n")
  end

  private def require_codes
    names = Set(String).new
    @examples.each do |example|
      example.codes.each do |line|
        case line
        when /^\s*require\s+"(.*?)"/
          names << %(require "#{$1}")
        end
      end
    end
#    build_require_code.try{|c| names << c} if names.empty?
    names.to_a.sort
  end

  private def declare_dynamically?
    @examples.each do |example|
      return true if example.codes.any?{|line| line =~ /^\s*(def|enum|class|module|struct)\s+/}
    end
    return false
  end

  ######################################################################
  ### prelude

  # PENDING: `Time.parse(a,b)` doesn't work in master
  
  PRETTY_TIME_CODE = {{ system("cat " + env("PWD") + "/lib/pretty/src/pretty/time.cr").stringify }}

  def prelude : String
    String.build do |s|
      s.puts "# https://github.com/maiha/pretty.cr/blob/master/src/pretty/time.cr"
      s.puts PRETTY_TIME_CODE
      s.puts "def Time.parse(value : String, fmt : String); Pretty::Time.parse(value); end"
    end
  end
end
