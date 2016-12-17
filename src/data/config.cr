class Data::Config < TOML::Config
  def_equals_and_hash toml

  DEFAULT = parse(Bundled::CONFIG_TOML)

  SYSTEM_COMPILER   = "crystal"
  COMPILED_COMPILER = "./crystal/bin/crystal"
  
  def self.current
    @@current ||= DEFAULT
  end

  def self.current=(config : Config)
    @@current = config
  end

  var source   : String = "(config.toml)"

  var sse      : Bool       = false
  var verbose  : Bool       = false
  var dryrun   : Bool       = false
  var interval : Time::Span = 3.seconds
  
  # [crystal]
  str "crystal/src_dir"
  str "crystal/bin"

  # [db]
  str  "db/sqlite"
  str  "db/heuristic_jnl"
  bool "db/query_logging"

  # [web]
  str  "web/host"
  int  "web/port"
  str  "web/env"
  str  "web/header_title"
  str  "web/logo_icon"
  str  "web/logo_color"

  str  "web/arrow_icon"
  str  "web/step1_head"
  str  "web/step2_head"
  str  "web/step3_head"
  str  "web/step4_head"
  str  "web/step5_head"
  str  "web/step1_icon"
  str  "web/step2_icon"
  str  "web/step3_icon"
  str  "web/step4_icon"
  str  "web/step5_icon"

  # [highlight]
  str     "highlight/version"
  str     "highlight/lang"
  str     "highlight/style"
  as_hash "highlight/custom"
  
  # [compile]

  ######################################################################
  ### cache

  var try_crystal_version : Try(String) = Try(String).try { Shell::Seq.run("crystal --version | grep -i crystal").stdout.chomp }

  ######################################################################
  ### accessor methods

  def build_logger(v = self.toml["logger"]?) : Logger
    case v
    when Nil
      return Logger.new(STDOUT)
    when Array
      return CompositeLogger.new(v.map{|i| build_logger(i)})
    when Hash(String, TOML::Type)
      return CompositeLogger.new([v.transform_values(&.to_s)])
    else
      raise NotFound.new("logger should be one of Array, Hash, Nil. but got #{v.class}");
    end
  end    

  def to_s(io : IO)
    max = @paths.keys.map(&.size).max
    @paths.each do |(key, val)|
      io.puts "  %-#{max}s = %s" % [key, val]
    end
  end

  private def pretty_dump(io : IO = STDERR)
    io.puts "[config] #{clue?}"
    io.puts to_s
  end
end

class Data::Config
  FILENAME = "config.toml"

  def self.empty
    parse("")
  end

  def self.parse_file(path : String)
    super(path).tap(&.source = path)
  end
  
  def self.load?(path : String?) : Config?
    # First, parse specified file if given
    return parse_file(path) if path

    # Second, try local dir if exists
    return parse_file(FILENAME) if File.exists?(FILENAME)

    # Otherwise, return nil
    return nil
  end
end
