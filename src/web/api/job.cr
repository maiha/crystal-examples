# Controls request to the background jobs.
# "*.ws" is unsed for a mark to detect WebSocket in Nginx

# Subscribe to the EventBus of the background jobs
ws "/job.ws" do |socket|
  connected = true
  socket.on_close do
    Web::Job.unsub(socket)
    connected = false
  end

  Web::Job.sub(socket)
  spawn do
    while connected
      sleep 1
    end
  end
end

# Resets database.
# This kicks `shell` to use cli function.
#
# Assumed Pjax, and returns the html of content part.
post "/job/db/reset" do |env|
  seq = Shell::Seq.run("#{PROGRAM_NAME} db reset")
  if seq.success?
    Pon.logger.info(seq.stdout)
    Models::Source.adapter.reset!
    slang "about/step"
  else
    Pon.logger.error(seq.log)
    render_error(env, seq.stdout)
  end
end

JOB_TABLE_NAMES = {{ Pon::Model.subclasses.map{|k| "#{k}.table_name".id} }}

post "/job/db/reset/:table" do |env|
  table = env.params.url["table"]
  JOB_TABLE_NAMES.includes?(table) ||
    raise ArgumentError.new("unknown table name: '#{table}'")

  seq = Shell::Seq.run("#{PROGRAM_NAME} db reset #{table}")
  if seq.success?
    Models::Source.adapter.reset!
    slang "about/step"
  else
    render_error(env, seq.stdout)
  end
end

# Extracts examples.
# This kicks `shell` to use cli function.
#
# Assumed Pjax, and returns the html of content part.
post "/job/extract/run" do |env|
  seq = Shell::Seq.run("#{PROGRAM_NAME} extract run")
  if seq.success?
    slang "about/step"
  else
    render_error(env, seq.stdout)
  end
end

# Kick the compiler to start.
# This uses `crystal` rather than `shell` for pubsub of the pregress.
#
# Assumed Ajax call, and returns JSON string as follows.
# [OK] {start: true}
# [NG] {start: false, reason: "Locked by ..."}
post "/job/compile/start" do |env|
  case try = Web::Job.try_start_compiler
  when Success
    hash = {"start" => true}
  when Failure(Web::Job::Locked)
    topic = try.err.topic
    if topic == "compile"
      hash = {"start" => true}  # Already started
    else
      hash = {"start" => false, "reason" => "Locked by #{topic}"}
    end
  when Failure
    hash = {"start" => false, "reason" => try.err.to_s}
  end
  render_json(env) { hash }
end

# Stop the background job of the compiler.
#
# Assumed Ajax call, and returns JSON string as follows.
# [OK] {stop: true}
# [NG] {stop: false, reason: "..."}
post "/job/compile/stop" do |env|
  case try = Web::Job.try_stop_compiler
  when Success
    hash = {"stop" => true}
  when Failure
    hash = {"stop" => false, "reason" => try.err?.to_s}
  end
  render_json(env) { hash }
end

# Kick the test to start.
# This uses `crystal` rather than `shell` for pubsub of the pregress.
#
# Assumed Ajax call, and returns JSON string as follows.
# [OK] {start: true}
# [NG] {start: false, reason: "Locked by ..."}
post "/job/test/start" do |env|
  case try = Web::Job.try_start_tester
  when Success
    hash = {"start" => true}
  when Failure(Web::Job::Locked)
    topic = try.err.topic
    if topic == "test"
      hash = {"start" => true}  # Already started
    else
      hash = {"start" => false, "reason" => "Locked by #{topic}"}
    end
  when Failure
    hash = {"start" => false, "reason" => try.err.to_s}
  end
  render_json(env) { hash }
end

# Stop the background job of the test.
#
# Assumed Ajax call, and returns JSON string as follows.
# [OK] {stop: true}
# [NG] {stop: false, reason: "..."}
post "/job/test/stop" do |env|
  case try = Web::Job.try_stop_tester
  when Success
    hash = {"stop" => true}
  when Failure
    hash = {"stop" => false, "reason" => try.err?.to_s}
  end
  render_json(env) { hash }
end

# pending
private def run_cli(env, args : String, &on_success)
  seq = Shell::Seq.run("#{PROGRAM_NAME} #{args}")
  if seq.success?
    yield
    slang "about/step", "application"
  else
    render_error seq.stdout
  end
end

private def render_error(env, obj)
  env.response.headers["Content-Type"] = "text/plain; charset=utf-8"
  env.response.status_code = 500
  env.response.puts obj.to_s
end
