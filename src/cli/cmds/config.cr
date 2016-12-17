Cmds.command "config" do
  include Data

  var require_config = false
  
  usage "example (key)  # show example"
  usage "show (key)     # show current setting"

  task "howto_install" do
    current_path = args.shift? || "(nil)"
    raise TOML::Config::NotFound.new <<-EOF
      No config files.
      It must exist or must be specified with the "-f" option.

      When using for the first time, create it as follows.

        #{PROGRAM_NAME} config example > examples.toml

      Then, check or change the settings in "examples.toml".
        [crystal]
        src_dir = "crystal/src"  # the path of crystal src directory

        [web]                    # for "web" command
        host = "0.0.0.0"
        port = 8080
      EOF
  end
  
  task "example" do
    example = Data::Config::DEFAULT

    if field = args.shift?
      k = field.split(".").last
      v = example[field.gsub(".", "/")]
      puts "%s = %s" % [k, v.inspect]
    else
      puts example
    end
  end

  task "show" do
    if key = args.shift?
      puts config[key.to_s]?.to_s
    else
      puts "# %s" % (config.source? || "(unknown)")
      puts config
    end
  end
end
