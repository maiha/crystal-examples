Cmds.command "compile" do
  include Job

  ######################################################################
  ### Usage
  
  usage "all   # setup and run"
  usage "setup # prepare compilation"
  usage "gen   # create files to compile"
  usage "run   # compile all examples"

  ######################################################################
  ### Variables

  var wiz = Data::Wizard.new(config)

  var interval : Time::Span = config.interval? || 3.seconds

  ######################################################################
  ### Tasks

  task "setup" do
    shell = Shell::Seq.new
    shell.run("#{PROGRAM_NAME} db run")
    shell.run("#{PROGRAM_NAME} extract run")
    if !shell.success?
      raise shell.log
    end
  end
  
  task "gen" do
    crystal = config.crystal_bin
    compile = Compile.new(wiz.examples, crystal: crystal, args: config.crystal_testing_args)
    # files are generated when Compile.new
  end
  
  task "run" do
    crystal = config.crystal_bin
    compile = Compile.new(wiz.examples, crystal: crystal, args: config.crystal_testing_args)
    compile.callback = ->(msg : Message) {
      info(msg.to_json)
      true
    }
    compile.run
  end
  
  task "all" do
    invoke_task("setup")
    invoke_task("run")
  end
end
