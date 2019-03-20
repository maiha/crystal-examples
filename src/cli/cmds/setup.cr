Cmds.command "setup" do
  PROGRAM_BIN = "crystal-examples"

  ######################################################################
  ### Usage
  
  usage "[dir] # create and setup a working directory"

  ######################################################################
  ### Variables

  var dir : String = task_name? || raise ArgumentError.new("Cannot setup Example project: Argument [DIR] is missing")
  var full_path : String = File.expand_path(dir)
  var config : Data::Config = Data::Config.current
  var wizard : Data::Wizard = Data::Wizard.new
  var result : Result = Result::OK
  var program_path : String = build_program_path # "/usr/local/bin/crystal-examples"

  FILES = {
    "Makefile"           => Data::Bundled::MAKEFILE,
    "config.toml"        => Data::Bundled::CONFIG_TOML,
    "docker-compose.yml" => Data::Bundled::DOCKER_COMPOSE,
  }

  enum Result
    OK
    CREATE
    OVERWRITE
    SKIP
    NOT_FOUND
  end

  ######################################################################
  ### Tasks

  def run
    STDOUT.puts "Setting up working directory in #{dir}/"
    create_dir
    create_files
    create_db
    copy_app
    check_src
    check_bin
    show_steps
  end

  private def needs_cd?
    File.expand_path(Dir.current) != full_path
  end
  
  private def show_steps
    STDOUT.puts

    if result == Result::NOT_FOUND
      STDOUT.puts "After fixing error. Try again!"
      STDOUT.puts "  $ cd #{dir}" if needs_cd?
      STDOUT.puts "  $ ./#{PROGRAM_BIN} setup ."
    else
      STDOUT.puts "Run web server in docker!"
      STDOUT.puts "  $ cd #{dir}" if needs_cd?
      STDOUT.puts "  $ make web"
    end
  end

  private def check_src
    if File.exists?("#{full_path}/crystal/src/array.cr")
      log_message("crystal/src", Result::OK)
    else
      log_message("crystal/src", Result::NOT_FOUND)
      msg = String.build do |s|
        s.puts "    => Put crystal src in '#{dir}/crystal/src'. For example,"
        s.puts "      $ cd #{dir}" if needs_cd?
        s.puts "      $ git clone https://github.com/crystal-lang/crystal.git"
      end
      STDOUT.puts msg.chomp.colorize(:light_red)
    end
  end

  private def check_bin
    case config.crystal_bin
    when Data::Config::SYSTEM_COMPILER
      log_message("crystal # system compiler", Result::OK)
    when Data::Config::COMPILED_COMPILER
      raw = "#{full_path}/crystal/.build/crystal"
      label = "%s # (compiled compiler)" % config.crystal_bin
      if File.exists?(raw)
        log_message(label, Result::OK)
      else
        log_message(label, Result::NOT_FOUND)
        msg = String.build do |s|
          s.puts "    => If you want to use compiled compiler with 'crystal/src', try"
          s.puts "      $ cd #{dir}" if needs_cd?
          s.puts "      $ make crystal"
          s.puts "    otherwise, set crystal path as 'bin' in 'config.toml'."
        end
        STDOUT.puts msg.chomp.colorize(:light_red)
      end
    else
      log_message("#{config.crystal_bin} # (custom)", Result::SKIP)
    end
  end
  
  private def create_dir
    if Dir.exists?(full_path)
      log_message("#{full_path}/", Result::SKIP)
    else
      Pretty.mkdir_p(dir)
      log_message("#{full_path}/", Result::CREATE)
    end
  end

  private def create_files
    FILES.each do |file, data|
      path = File.join(dir, file)
      if File.exists?(path)
        log_message(file, Result::SKIP)
      else
        File.write(path, data)
        log_message(file, Result::CREATE)
      end
    end
  end

  private def create_db
    action = File.exists?(File.join(full_path, config.db_sqlite)) ? Result::OVERWRITE : Result::CREATE
    if wizard.valid2
      log_message(config.db_sqlite, Result::SKIP)
    else
      shell = Shell::Seq.run("cd #{full_path} && #{PROGRAM_NAME} db run 2>&1")
      if shell.success?
        log_message(config.db_sqlite, action)
      else
        abort "error: create #{config.db_sqlite}\n" + shell.log
      end
    end
  end

  private def copy_app
    src  = program_path
    dst  = "#{full_path}/#{PROGRAM_BIN}"
    this = Shard.git_description
    info = this.sub(/ /, " # ")
    if File.exists?(dst)
      that = `#{dst} --version`.chomp
      if this == that
        log_message(info, Result::OK)
      else
        shell = Shell::Seq.run("cp -pf #{src} #{dst}")
        if shell.success?
          log_message(info, Result::OVERWRITE)
        else
          abort shell.log
        end
      end
    else
      shell = Shell::Seq.run("cp -pf #{src} #{dst}")
      if shell.success?
        log_message(info, Result::CREATE)
      else
        abort shell.log
      end
    end
  end

  private def build_program_path : String
    shell = Shell::Seq.run("/bin/which #{PROGRAM_NAME}")
    if shell.success?
      buf = shell.stdout.chomp
      if buf =~ /\A(\S+)\Z/
        return buf
      end
    end

    warn "error: build_program_path (use PROGRAM_NAME itself)\n" + shell.log
    return PROGRAM_NAME
  end
  
  private def log_message(msg : String, result : Result)
    color = {
      Result::OK        => :light_green,
      Result::CREATE    => :light_green,
      Result::OVERWRITE => :light_yellow,
      Result::SKIP      => :light_cyan,
      Result::NOT_FOUND => :light_red,
    }[result]?
    text   = result.to_s.gsub(/_/, " ").downcase
    margin = " " * (9 - text.size)
    action = color ? text.colorize(color) : text
    STDOUT.puts "  %s%s  %s" % [action, margin, msg]

    self.result = [result, result()].max
  end
end
