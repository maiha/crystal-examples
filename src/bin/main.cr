require "../examples"

class Main < Cmds::Cli
  USAGE = <<-EOF
    Usage: {{program}} [options] [commands]

    Options:
    {{options}}

    Commands:
      #{Cmds.names.inspect}
    EOF

  var cmd    : Cmds::Cmd
  var config : Data::Config = Data::Config.empty

  def run
    run(ARGV)
  end

  def run(args)
    if args.delete("--version")
      puts Shard.git_version
      exit(0)
    end

    debug = !!args.delete("-d")
#    setup_logs(debug)

    self.config = Data::Config.load?(nil) || Data::Config::DEFAULT
#    config.sse      = sse
#    config.interval = interval.try(&.seconds)
#    config.verbose  = verbose
#    config.dryrun   = dryrun
    Data::Config.current = config

    # database
    Pon.query_logging = true if config.db_query_logging?
    Pon::Adapter::Sqlite.setting.url = "sqlite3:%s" % config.db_sqlite?

    # build `cmd`, then check config file
    cmd = Cmds[args.shift?].new
    cmd.config = config
    cmd.debug = debug
    cmd.run(args)

  rescue err : ArgumentError
    msg = err.to_s
    Log.fatal { msg } if msg.presence
    exit 1
  rescue err
    handle_error(cmd, err)
  end
  
#  option rcpath   : String?, "-f <config>", "Config file (default: 'examples.toml')", nil
#  option nocolor  : Bool   , "--no-color", "Disable colored output", false
#  option level    : String?, "-l <LEVEL>", "Logger level string: DEBUG, INFO, ...", nil
#  option sse      : Bool   , "--sse", "Enable SSE output (logger is disabled)", false
#  option interval : Int32? , "-i <SEC>", "Output interval", nil
#  option dryrun   : Bool   , "-n", "Enable dryrun mode", false
#  option verbose  : Bool   , "-v", "Enable verbose output", false
#  option version  : Bool   , "--version", "Print the version and exit", false
#  option help     : Bool   , "--help"   , "Output this help and exit" , false

  def on_error(err)
    # In SSE mode the logger has been deleted, so create a new one as STDERR.

    case err
    when Cmds::Finished
      exit 0
    when TOML::Config::NotFound, TOML::ParseException
      Log.error { red("ERROR: #{err}") }
      exit 1
    when Cmds::ArgumentError
      Log.error { red("ERROR: #{err}") }
      Log.error { cmd.class.pretty_usage(prefix: " ") }
      exit 2
    when Cmds::CommandNotFound, Cmds::TaskNotFound
      Log.error { err }
      exit 3
    when SQLite3::Exception
      Log.error { red("#{err.class}: #{err}") }
      exit 21
    when Data::Wizard::NotReady
      Log.error { red(err.to_s) }
      exit 51
    when Errno
      Log.error { red(err) }
      exit 91
    when Cmds::Abort
      Log.error { red(Pretty.error(err).message) }
      Log.error { "ERROR: #{err}" }
      exit 100
    else
      Log.error { red(Pretty.error(err).message) }
      Log.error { "ERROR: #{err} (#{err.class.name})" }
      Log.error { err.inspect_with_backtrace }
      Log.error { red(Pretty.error(err).where) } # This may kill app
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
