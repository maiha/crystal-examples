class Job::Generate
  SEQ_MARK = "# EXAMPLE_SEQ="
  TEST_PASSED_SEQ_MARK = "TEST_PASSED_SEQ="

  var required_names : Array(String) = Array(String).new
  
  # src is a relative name of the crystal src like 'array.cr'
  def initialize(@src : String, @examples : Array(Models::Example), @heuristics : Heuristics)
    # Gather required library names, then put them into head of the file.
    @examples.each do |example|
      required_names.concat(example.required_names)
    end
  end

  ######################################################################
  ### code
  
  def code : String
    String.build do |s|
      if heuristic = @heuristics.requires[@src]?
        s.puts "# [heuristic:%d] %s" % [heuristic.id, heuristic.to_jnl]
        s.puts %|require "%s"| % heuristic.by
      end

      required_names.uniq.each do |name|
        s.puts %|require "%s"| % name
      end

      # Stack context as module to avoid conflicated class/module/enum.
      defined_constants    = Set(String).new
      stacked_module_names = Array(String).new
      
      @examples.each do |example|
        s.puts "# %s (%03d)" % [example.clue, example.seq]
        # embeds mark of seq number as comment
        s.puts (SEQ_MARK + example.seq.to_s)

        code = build_compile_code(example)

        if heuristic = @heuristics.skip_compile[example.sha1]?
          s.puts "# #{heuristic.to_s}"
          s.puts code.gsub(/^/m, "# ")
        else

          # If re-assigned previous constants, modulize this code block
          constant_conflicted = false
          example.defined_constant_names.each do |name|
            if defined_constants.includes?(name)
              constant_conflicted = true
            end
            defined_constants << name
          end

          if constant_conflicted
            # example.src  # => "array.cr"
            # example.line # => 81
            module_name = "#{example.class_name}#{example.line}" # "Array81"
            stacked_module_names << module_name
            s.puts "module #{module_name}"
          end

          s.puts code
        end
      end

      stacked_module_names.each do |module_name|
        s.puts "end # #{module_name}"
      end
    end
  end

  private def build_compile_code(example : Models::Example)
    String.build do |s|
      s.puts "# %s\n" % example.clue
      example.codes.each do |line|
        case line
        when /#.*?error/i
          s.puts "# #{line}"
        when /^require "/
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
      s.puts require_helper_code
      
      if heuristic = @heuristics.requires[@src]?
        s.puts "# [heuristic:%d] %s" % [heuristic.id, heuristic.to_jnl]
        s.puts %|require "%s"| % heuristic.by
      end

      required_names.uniq.each do |name|
        s.puts %|require "%s"| % name
      end

      s.puts body
    end
  end

  private def spec_body : String
    String.build do |s|
      # Stack context as module to avoid conflicated class/module/enum.
      defined_constants    = Set(String).new
      stacked_module_names = Array(String).new

      @examples.each do |example|
        s.puts "# %s (%03d)" % [example.clue, example.seq]
        # Embeds mark of seq number
        s.puts (SEQ_MARK + example.seq.to_s)

        code = build_spec_code(example)
        if heuristic = @heuristics.skip_test[example.sha1]? || @heuristics.skip_compile[example.sha1]?
          s.puts "# #{heuristic.to_s}"
          s.puts code.gsub(/^/m, "# ")
        else

          # If re-assigned previous constants, modulize this code block
          constant_conflicted = false
          example.defined_constant_names.each do |name|
            if defined_constants.includes?(name)
              constant_conflicted = true
            end
            defined_constants << name
          end

          if constant_conflicted
            # example.src  # => "array.cr"
            # example.line # => 81
            module_name = "#{example.class_name}#{example.line}" # "Array81"
            stacked_module_names << module_name
            s.puts "module #{module_name}"
          end

          s.puts code

          # Embeds mark of seq number after the spec code has been finished.
          s.puts(%|puts "#{TEST_PASSED_SEQ_MARK}#{example.seq}" # :nocode:|)
        end
        s.puts ""
      end

      stacked_module_names.each do |module_name|
        s.puts "end # #{module_name}"
      end
    end
  end

  private def build_spec_code(example : Models::Example)
    example.codes.map{|line| CommentSpec.parse(line)}.join("\n")
  end

  private def declare_dynamically?
    @examples.each do |example|
      return true if example.codes.any?{|line| line =~ /^\s*(def)\s+/}
    end
    return false
  end

  ######################################################################
  ### prelude

  def require_helper_code : String
    # @src : "json/to_json.cr"
    # PATH : "tmp/json/to_json/all_spec.cr"
    # WANT : "../../helper"

    relative = "../" * (@src.count("/") + 1) # "../../"
    code = %|require "#{relative}helper"|
    return code
  end
end
