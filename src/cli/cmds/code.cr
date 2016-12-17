Cmds.command "code" do
  ######################################################################
  ### Usage
  
  usage "array                     # => {size: 79}"
  usage "array/3 body              # print 3rd example of array.cr"
  usage "array/3 body set < foo.cr # update body of 3rd example by file"

  ######################################################################
  ### Variables

  var example : Models::Example = load_example
  
  ######################################################################
  ### Tasks

  def run
    field   = args.shift?
    sub_cmd = args.shift? || "get"

    if field
      if Models::Example::FIELD_NAMES.includes?(field)
        case sub_cmd
        when "get"
          puts example[field]
        when "set"
          raise ArgumentError.new("sorry. primary key cannot be set") if field == "id"
          example.code = ARGF.gets_to_end
          example.save!
        else
          raise ArgumentError.new("sub cmd expects 'set', but '#{sub_cmd}' found")
        end
      else
        raise ArgumentError.new("expected %s, but got %s" % [Models::Example::FIELD_NAMES.inspect, field])
      end
    else
      puts Pretty.json(example.to_json)
    end
  end

  ######################################################################
  ### Functions

  private def load_example
    case task_name
    when %r{^(.*)/(\d+)$}
      query = "WHERE path = '#{$1}.cr' AND seq = #{$2}"
      return Models::Example.all(query).first? || raise ArgumentError.new
    else
      raise ArgumentError.new
    end
  rescue err : ArgumentError
    raise ArgumentError.new("no examples for '#{task_name}'")
  end
end
