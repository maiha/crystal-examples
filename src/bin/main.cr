require "../examples"

class Main
  include Opts

  USAGE = <<-EOF
    Usage: {{program}} [options] [commands]

    Options:
    {{options}}

    Commands:
      #{Cmds.names.inspect}
    EOF

  option rcpath   : String?, "-f <config>", "Config file (default: 'examples.toml')", nil

  option nocolor  : Bool   , "--no-color", "Disable colored output", false
  option level    : String?, "-l <LEVEL>", "Logger level string: DEBUG, INFO, ...", nil
  option sse      : Bool   , "--sse", "Enable SSE output (logger is disabled)", false
  option interval : Int32? , "-i <SEC>", "Output interval", nil
  option dryrun   : Bool   , "-n", "Enable dryrun mode", false
  option verbose  : Bool   , "-v", "Enable verbose output", false
  option version  : Bool   , "--version", "Print the version and exit", false
  option help     : Bool   , "--help"   , "Output this help and exit" , false

  var cmd    : Cmds::Cmd
  var logger : Logger = Logger.new(STDOUT).tap(&.formatter = "{{prog=[%s] }}{{message}}")
  var config : Data::Config = Data::Config.empty

  def run
    # setup
    self.config     = Data::Config.load?(rcpath) || Data::Config::DEFAULT
    config.sse      = sse
    config.interval = interval.try(&.seconds)
    config.verbose  = verbose
    config.dryrun   = dryrun
    Data::Config.current = config

    if sse
      self.logger  = Logger.new(nil)
    else
      self.logger  = config.build_logger
      logger.level = Logger::Severity.parse(level.not_nil!) if level?
    end

    # database
    Pon.logger = logger
    Pon.query_logging = config.db_query_logging?
    Pon::Adapter::Sqlite.setting.url = "sqlite3:%s" % config.db_sqlite?
    
    # build `cmd`, then check config file
    self.cmd = Cmds[args.shift?.to_s].new
#      Cmds["config"].run(["howto_install", rcpath || "(nil)"])
    
    # execute
    cmd.config = config
    cmd.logger = logger
    cmd.run(args)
  end

  def on_error(err)
    # In SSE mode the logger has been deleted, so create a new one as STDERR.
    logger = config.sse? ? Logger.new(STDERR) : self.logger

    case err
    when Cmds::Finished
      exit 0
    when TOML::Config::NotFound, TOML::ParseException
      logger.error red("ERROR: #{err}")
      exit 1
    when Cmds::ArgumentError
      logger.error red("ERROR: #{err}")
      logger.error cmd.class.pretty_usage(prefix: " ")
      exit 2
    when Cmds::CommandNotFound, Cmds::TaskNotFound
      logger.error err
      exit 3
    when SQLite3::Exception
      logger.error red("#{err.class}: #{err}")
      exit 21
    when Data::Wizard::NotReady
      logger.error red(err.to_s)
      exit 51
    when Errno
      logger.error red(err)
      exit 91
    when Cmds::Abort
      logger.error red(Pretty.error(err).message)
      logger.error "ERROR: #{err}"
      exit 100
    else
      logger.error red(Pretty.error(err).message)
      logger.error "ERROR: #{err} (#{err.class.name})"
      logger.error(err.inspect_with_backtrace)
      logger.error red(Pretty.error(err).where) # This may kill app
      exit 100
    end
  end

  {% for c in %w( red ) %}
  private def {{c.id}}(str)
    nocolor ? str.to_s : str.to_s.colorize(:{{c.id}})
  end
  {% end %}
end

Main.run
