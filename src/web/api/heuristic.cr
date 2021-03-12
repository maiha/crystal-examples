private def heuristic_jnl_path : String
  Data::Config.current.db_heuristic_jnl
end

put "/heuristic/dump" do |env|
  safe(env) {
    Models::Heuristic.dump!(heuristic_jnl_path)
    "done"
  }
end

put "/heuristic/load" do |env|
  safe(env) {
    Models::Heuristic.load!(heuristic_jnl_path)
    "done"
  }
end

get "/heuristic/diff" do |env|
  safe(env) {
    Dir.cd(Dir.tempdir) do
      File.write("orig.jnl", Data::Bundled::HEURISTIC_JNL)
      File.write("dump.jnl", Models::Heuristic.dump)
      buf = Shell::Seq.run("diff orig.jnl dump.jnl 2>&1").stdout
      "<pre>%s</pre>" % (buf.empty? ? "(nothing changed)" : buf)
    end
  }
end

# delete compile heuristic for the example
delete "/heuristic/compile/:example_id" do |env|
  safe(env) {
    example = Models::Example.find(param_i("example_id").to_i64)
    example.delete_compile_heuristic!
    render_compile_example(example.id)
  }
end

put "/heuristic/compile/:id/:reason" do |env|
  safe(env) {
    example = Models::Example.find(param_i("id").to_i64)
    Models::Heuristic.register!(
      action: Models::Heuristic::ACTION_COMPILE,
      target: example.sha1,
      by: param("reason"),
      comment: example.clue + Pretty.now.to_s(":%Y%m%d")
    )

    # reload the model to refresh view
    render_compile_example(example.id)
  }
end

# delete test heuristic for the example
delete "/heuristic/test/:example_id" do |env|
  safe(env) {
    example = Models::Example.find(param_i("example_id").to_i64)
    example.delete_test_heuristic!
    render_test_example(example.id)
  }
end

put "/heuristic/test/:id/:reason" do |env|
  safe(env) {
    example = Models::Example.find(param_i("id").to_i64)
    Models::Heuristic.register!(
      action: Models::Heuristic::ACTION_TEST,
      target: example.sha1,
      by: param("reason"),
      comment: example.clue + Pretty.now.to_s(":%Y%m%d")
    )

    # reload the model to refresh view
    render_test_example(example.id)
  }
end

put "/heuristic/require/:id/:name" do |env|
  safe(env) {
    name = param("name")
    example = Models::Example.find(param_i("id").to_i64)
    Models::Heuristic.register!(
      action: "require",
      target: example.src,
      by: name,
      comment: example.clue + Pretty.now.to_s(":%Y%m%d")
    )

    %|Added 'require "#{name}"'! Try compile again!|
  }
end

private def safe(env, &block)
  yield
rescue err
  env.response.headers["Content-Type"] = "text/plain; charset=utf-8"
  env.response.status_code = 500
  env.response.puts err.to_s
  Log.error { err.to_s }
end

private def render_compile_example(id : Int64)
  example = Models::Example.find(id)
  heuristics = Job::Heuristics.new
  String.build do |buf|
    buf << slang "compiled/example"
    buf << "<script>hljs.initHighlightingOnLoad();</script>"
  end    
end

private def render_test_example(id : Int64)
  example = Models::Example.find(id)
  heuristics = Job::Heuristics.new
  String.build do |buf|
    buf << slang "tested/example"
    buf << "<script>hljs.initHighlightingOnLoad();</script>"
  end    
end
