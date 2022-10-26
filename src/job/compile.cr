require "./message"
require "./worker"

class Job::Compile
  include Worker
  include Models

  var tmp_dir       = "tmp"
  var limit : Int32 = Int32::MAX
  var all_passed    = Set(String).new
  var targets       = Array(Target).new
  var heuristics    = Heuristics.new
  var timeout       = 1.minute
  
  def initialize(examples : Array(Example), @crystal : String, @args : String)
    examples.each(&.compiled = Data::Status::UNKNOWN)
    examples.sort_by(&.src).group_by(&.src).each do |src, ary|
      targets << generates_target(src: src, examples: ary.sort_by(&.seq))
    end
  end

  # true : finished all targets
  # false: suspended by some reasons
  def run : Bool
    targets.each_with_index do |target, index|
      Log.debug { "compile(%s)" % target.path }
      cache  = Models::CompileCache.from(src: target.src)
      cached = cache.success?

      run(target, cache)
      pct  = (((index + 1) * 100.0) / targets.size).trunc.to_i32
      data = target.summarize_status_about(&.compiled)

      logging_result(cached, topic, pct, target, data, cache)
      notify_user(Message.new(topic, pct, data))
    end
    raise Finished.new(100)

  rescue msg : Finished    
    return msg.pct == 100
  end
  
  def notify_user(msg : Message)
    has_next = callback.call(msg)
    if !has_next
      callback.call(Message.halt(msg.topic))
      raise Finished.new(msg.pct)
    end
  end

  def logging_result(cached, topic, pct, target, data, cache)
    if target.examples.any?
      status = target.examples.map(&.compiled.floor).max
      sec = ("%5.1fs" % cache.duration?.try(&.total_seconds) rescue " T/O ")
      sec = "(cache)" if cached
      msg = "%7s [%s]%3d%%: %s" % [sec, topic, pct, data]
      if cached
        Log.info { msg.colorize(:cyan) }
      else
        case status
        when .success? ; Log.info { msg.colorize(:green) }
        when .skip?    ; Log.info { msg.colorize(:cyan) }
        when .warn?    ; Log.warn { msg.colorize(:yellow) }
        else           ; Log.error { msg.colorize(:red) }
        end
      end
    end
  end

  # create a Target with generating its source file.
  private def generates_target(src : String, examples : Array(Example)) : Target
    # convert "array.cr" to "tmp/array/all.cr"
    path = File.join(tmp_dir, src.sub(/\.cr$/, ""), "all.cr")
    body = Generate.new(src, examples, heuristics).code
    Pretty.write(path, body)

    Log.debug { "writes target code: #{path}" }

    return Target.new(path: path, examples: examples, src: src)
  end
  
  private def run(target : Target, cache)
    Log.debug { "compile(%s)" % target.src }
    if cache.success?
      # set `success` flag and returns true when positive cache hit
      update_status(target) { Data::Status::SUCCESS }
    else
      Log.debug { "  # 2. run compile" }
      compile(target, cache)
    end

    Log.debug { "  # 3. save models to update `compile` status" }
    Example.adapter.transaction do
      target.examples.each(&.save!)
    end
  end

  protected def compile(target : Target, cache)
    if cache.success?
      # set `success` flag and returns true when positive cache hit
      update_status(target) { Data::Status::SUCCESS }
      return true
    end

    cache.start!

    finished  = Channel(Shell::Seq).new
    timeouted = Channel(Time::Span).new

    cmd = "LC_ALL=C #{@crystal} build #{@args} -o /dev/null --no-color %s 2>&1" % target.path
    Log.debug { cmd }
    spawn do
      shell = Shell::Seq.run(cmd)
      finished.send(shell)
    end

    spawn do
      sleep timeout
      timeouted.send(timeout)
    end

    success = false
    
    select
    when span = timeouted.receive
      cache.exit_code = -1
      cache.log    = "timeout: #{span}"
    when shell = finished.receive
      success = shell.success?
      cache.exit_code = shell.exit_code
      cache.log       = shell.log.to_s
      unless success
        error = CompileErrorParser.new(cache.log, File.read(target.path))
        cache.error_type  = error.error_type
        cache.error_value = error.error_value
      end
    end

    cache.stopped_at  = Pretty.now
    cache.save!

    if success
      update_status(target) { Data::Status::SUCCESS }
    else
      update_status_by_log(target, cache.log)
    end

    return success
  end

  private def update_status_by_log(target : Target, log : String)
    path = target.path   # "array.cr"
    base = path.gsub(/\.cr$/,"") # "array"

    Log.debug { "compile failed. trying to find partial successes...(#{path})" }

    parser = CompileErrorParser.new(log, File.read(target.path))
    line_number  = parser.line_number?
    success_seqs = parser.success_seqs?

    Log.debug { "parsed log. (line=#{line_number.inspect}, seqs=#{success_seqs.inspect})" }

    if seqs = success_seqs
      update_status(target) {|s|
        seqs.includes?(s.seq) ? Data::Status::SUCCESS : Data::Status::FAILURE
      }

      Log.info { "[compile] #{path}: compile error at seq=#{parser.error_seq}, mark success to seqs=#{seqs.inspect}" }
    else
      update_status(target) { Data::Status::FAILURE }
      Log.error { "[compile] #{path}: Compilation failed. And we failed to parse the error message too." }
      Log.debug { log.split(/\n/, 6).first(5).map{|i| "  #{i}"}.join("\n") }
    end
  end

  private def update_status(target : Target, &block)
    target.examples.each do |e|
      next if e.compiled.success?  # NOP
      if heuristic = heuristics.skip_compile[e.sha1]?
        e.compiled = heuristic.status
      else
        e.compiled = yield(e)
      end
    end
  end
end
