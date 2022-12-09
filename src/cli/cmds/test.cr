Cmds.command "test" do
  include Job

  ######################################################################
  ### Usage
  
  usage "setup # prepare test"
  usage "gen   # create files to test"

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
    compile = Test.new(wiz.examples, crystal: crystal, args: config.crystal_testing_args)
    # files are generated when Test.new
  end
end
