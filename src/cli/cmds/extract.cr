Cmds.command "extract" do
  ######################################################################
  ### Usage
  
  usage "run   # extract examples from source codes"

  ######################################################################
  ### Variables

  var scaned_files    : Array(String) = scan_files
  var last_flushed_at : Time          = Pretty.now
  var flush_interval  : Time::Span    = config.interval? || 3.seconds
  var flush_count                     = 10000
  var dirty_records                   = Array(Pon::Persistence).new

  ######################################################################
  ### Tasks

  task "run" do
    Models::Source.delete_all
    Models::Example.delete_all
    Models::Spec.delete_all

    scaned_files.each_with_index do |file, i|
      flush_database!(i)
      
      source   = Data::Source.parse(file)
      comments = source.comments.select(&.crystal?)

      debug "%s: %d" % [source.path, comments.size]
      if err = source.error?
        error "%s: %s" % [source.path, err]
      end
      status = source.error? ? Data::Status::FAILURE : Data::Status::SUCCESS

      dirty_records << Models::Source.new(path: source.path, count: comments.size, error: source.error?, extract: status)

      if comments.any?
        extractor = Job::Extract.new(relative: source.path, comments: comments)
        dirty_records.concat(extractor.run)
      end
    end

    flush_database!(100, absolute: true)
  end

  private def scan_files : Array(String)
    src_dir = config.crystal_src_dir
    files   = Array(String).new

    if Dir.exists?(src_dir)
      dir = src_dir.chomp("/")
      Dir.glob("#{dir}/**/*.cr").sort.each do |file|
        next if is_system?(file)
        files << file
      end
    else
      files << src_dir
    end

    return files
  end

  private def is_system?(file) : Bool
    case file
    when %r(/compiler/), /^lib_c/
      true
    else
      false
    end
  end

  ######################################################################
  ### Functions

  # `flush_database!` writes to DB
  # 1. flush dirty sources to "sources"
  # 2. write parsing progress to "system_info"
  private def flush_database!(value : Int32, absolute = false)
    should_flush = absolute
    should_flush ||= (dirty_records.size > flush_count)
    should_flush ||= (Pretty.now - last_flushed_at > flush_interval)

    if should_flush
      if absolute
        v = value
      elsif scaned_files.empty?
        v = 0
      else
        v = (value * 100.0 / scaned_files.size).trunc
        v = [0, [v.to_i, 100].min].max
      end

      info "flush_database: %d%% (with %d records)" % [v, dirty_records.size]
      Models::Source.adapter.transaction do
        dirty_records.each(&.save!)
      end

      sse("extract", {"parsed" => v, "size" => dirty_records.size})

      dirty_records.clear

      self.last_flushed_at = Pretty.now
    end
  end
end
