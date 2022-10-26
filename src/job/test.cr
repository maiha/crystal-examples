require "./message"
require "./worker"

class Job::Test
  include Worker
  include Models

  var tmp_dir       = "tmp"
  var limit : Int32 = Int32::MAX
  var all_passed    = Set(String).new
  var targets       = Array(Target).new
  var heuristics    = Heuristics.new
  var timeout       = 1.minute

  def initialize(examples : Array(Example), @crystal : String, @args : String)
    examples.each(&.tested = Data::Status::UNKNOWN)
    examples.sort_by(&.src).group_by(&.src).each do |src, ary|
      targets << generates_target(src: src, examples: ary.sort_by(&.seq))
    end

    # Resolve the absolute path of `@crystal` first, because the binary
    # will be called from some other dir.
    if @crystal =~ /\s/
      # Give up when the string contains any spaces,
    else
      @crystal = File.expand_path(@crystal)
    end
  end

  # true : finished all targets
  # false: suspended by some reasons
  def run : Bool
    targets.each_with_index do |target, index|
      Log.debug { "test(%s)" % target.path }
      cache  = Models::TestCache.from(src: target.src)
      cached = cache.success?

      run(target, cache)
      pct  = (((index + 1) * 100.0) / targets.size).trunc.to_i32
      data = target.summarize_status_about(&.tested)

      logging_result(cached, topic, pct, target, data, cache)
      notify_user(Message.new(topic, pct, data))
    end
    raise Finished.new(100)

  rescue msg : Finished    
    return msg.pct == 100
  end

  private def run(target : Target, cache)
    if cache.success?
      # set `success` flag and returns true when positive cache hit
      update_status(target) { Data::Status::SUCCESS }
    else
      Log.debug { "  # 2. run spec" }
      test(target, cache)
    end

    Log.debug { "  # 3. save models to update `spec` status" }
    Example.adapter.transaction do
      target.examples.each(&.save!)
    end
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
      status = target.examples.map(&.tested.floor).max
      sec = ("%5.1fs " % cache.duration?.try(&.total_seconds) rescue " T/O ")
      sec = "(cache)" if cached
      msg = "%7s[%s]%3d%%: %s" % [sec, topic, pct, data]
      if cached
        Log.info { msg.colorize(:yellow) }
      else
        case status
        when .pending? ; Log.info { msg.colorize(:cyan) }
        when .success? ; Log.info { msg.colorize(:green) }
        when .warn?    ; Log.warn { msg.colorize(:yellow) }
        else           ; Log.error { msg.colorize(:red) }
        end
      end
    end
  end

  # create a Target with generating its source file.
  private def generates_target(src : String, examples : Array(Example)) : Target
    # convert "array.cr" to "tmp/array/all.cr"
    path = File.join(tmp_dir, src.sub(/\.cr$/, ""), "all_spec.cr")
    body = Generate.new(src, examples, heuristics).spec
    Pretty.write(path, body)

    Log.debug { "writes target code: #{path}" }

    return Target.new(path: path, examples: examples, src: src)
  end

  protected def pending?(sha1 : Data::SHA1) : Models::Heuristic?
    heuristics.skip_test[sha1]? || heuristics.skip_compile[sha1]?
  end
  
  protected def test(target : Target, cache : Models::TestCache) : Bool
    if cache.success?
      # set `success` flag and returns true when positive cache hit
      update_status(target) { Data::Status::SUCCESS }
      return true
    end

    cache.start!

    finished  = Channel(Shell::Seq).new
    timeouted = Channel(Time::Span).new

    # Prepare a working directory each time we run spec.
    # ** The sample code ** has side effects and mainly affects local files.
    # Otherwise, even if it passes first time, it will fail at the second run.

    path = target.path                                   # "tmp/array/all_spec.cr"
    working_dir = File.dirname(target.path) + "/working" # "tmp/array/working
    relative_path = "../" + File.basename(path)          # "../all_spec.cr"
    Pretty::Dir.clean(working_dir)

    spawn do
      # Run as **code** rather than **spec** to capture stdout markers.
      shell = Shell::Seq.run("cd #{working_dir} && LC_ALL=C #{@crystal} run #{@args} #{relative_path} 2>&1")
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
      cache.log    = "timeouted: #{span}"
    when shell = finished.receive
      success = shell.success?
      cache.exit_code = shell.exit_code
      cache.log       = shell.log.to_s
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
    Log.debug { "test failed. trying to find partial successes...(#{target.path})" }

    parser = TestPassedParser.new(log)
    success_seqs = parser.success_seqs?

    Log.debug { "parsed log. (seqs=#{success_seqs.inspect})" }

    if seqs = success_seqs
      update_status(target) {|s|
        seqs.includes?(s.seq) ? Data::Status::SUCCESS : Data::Status::FAILURE
      }
      Log.info { "[test] #{target.src}: Test failed. But some specs passed. seqs=#{seqs.inspect}" }
    else
      update_status(target) { Data::Status::FAILURE }
      Log.info { "[test] #{target.src}: Test failed. And no examples passed." }
      Log.debug { log.split(/\n/, 6).first(5).map{|i| "  #{i}"}.join("\n") }
    end
  end

  private def update_status(target : Target, &block)
    target.examples.each do |e|
      next if e.tested.success?  # NOP
      if heuristic = heuristics.skip_test[e.sha1]? || heuristics.skip_compile[e.sha1]?
        e.tested = heuristic.status
      else
        e.tested = yield(e)
      end
    end
  end
end
