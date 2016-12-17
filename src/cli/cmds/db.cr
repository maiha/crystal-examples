Cmds.command "db" do
  ######################################################################
  ### Usage
  
  usage "run           # ensures that database exists"
  usage "clean         # deletes database"
  usage "reset <TABLE> # clean and build database or table "
  usage "console       # connect to db via 'sqlite3' command"
  usage "schema        # show schema via 'sqlite3' command"
  usage "heuristic dump <FILE> # dump heuristic (default: heuristic.jnl)"
  usage "heuristic load <FILE> # load heuristic (default: heuristic.jnl)"
  
  ######################################################################
  ### Variables
  
  TABLE_NAMES = {{ Pon::Model.subclasses.map{|k| "#{k}.table_name".id} }}

  var path : String = config.db_sqlite

  ######################################################################
  ### Tasks

  task "run" do
    migrate_database
  end

  task "clean" do
    delete_database
  end

  task "reset" do
    if table = args.shift?
      migrate_database(table)
    else
      delete_database
      migrate_database
    end
  end

  task "console" do
    bin = sqlite3_bin!
    debug "execute: #{bin} #{path}"
    Process.exec bin, [path]
  end

  task "schema" do
    seq = Shell::Seq.run("echo .schema | #{sqlite3_bin!} #{path}")
    if seq.success?
      STDOUT.puts seq.stdout
    else
      abort seq.log
    end
  end

  task "heuristic" do
    action = args.shift?
    path   = args.shift? || config.db_heuristic_jnl
    case action
    when "dump"
      Models::Heuristic.dump!(path)
      msg = "dump to '%s' (%d actions)" % [path, File.read(path).count("\n")]
      info msg.colorize(:green)
    when "load"
      Models::Heuristic.load!(path)
      msg = "load from '%s' (%d actions)" % [path, Models::Heuristic.count]
      info msg.colorize(:green)
    else
      raise ArgumentError.new("needs ation: 'dump' or 'load'")
    end
  end

  ######################################################################
  ### Functions

  private def migrate_database(only_table : String? = nil)
    info "migrate database: #{path} #{only_table}"
    tables = Models::Source.adapter.tables rescue Array(String).new

    if name = only_table
      TABLE_NAMES.includes?(name) || raise ArgumentError.new("unknown table: '#{name}'")
    end
    
    info "tables: %s" % (only_table || tables).inspect
    {% begin %}
    {% for k in Pon::Model.subclasses %}
      name  = {{k.id}}.table_name
      if only_table
        if only_table == name
          {{k.id}}.migrate!
          info "  + create  {{k.id}}(#{name})".colorize(:green)
          {{k.id}}.seed!
        end
      else
        found = tables.includes?(name)
        if found
          info "  skipped  {{k.id}}(#{name})"
        else
          {{k.id}}.migrate!
          info "  + new    {{k.id}}(#{name})".colorize(:green)
          {{k.id}}.seed!
        end
      end
    {% end %}
    {% end %}
  end

  private def delete_database
    if File.exists?(path)
      File.delete(path)
      info "deleted database: #{path}"
    else
      debug "skip: no database found"
    end
  end
  
  private def sqlite3_bin! : String
    Process.find_executable("sqlite3") || abort "sqlite3 not found"
  end
end
