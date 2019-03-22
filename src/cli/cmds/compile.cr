Cmds.command "compile" do
  include Job

  ######################################################################
  ### Usage
  
  usage "all   # setup and run"
  usage "setup # prepare compilation"
  usage "run   # compile all examples"
#  usage "full  # re-compile all examples"
#  usage "clean # clean results"

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
  
  task "run" do
    crystal = config.crystal_bin
    compile = Compile.new(wiz.examples, crystal: crystal, args: config.crystal_testing_args)
    compile.tap(&.logger = logger)
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
