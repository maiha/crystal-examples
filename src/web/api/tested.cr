get "/tested" do |env|
  env.breadcrumbs << Web::Breadcrumb.new("/tested", "test")

  status_filter = nil
  slang "tested/index", "application"
end

get "/tested/_/:status" do |env|
  # same as "/compiled"
  status = env.params.url["status"]

  env.breadcrumbs << Web::Breadcrumb.new("/tested", "test")
  env.breadcrumbs << Web::Breadcrumb.new("/tested/_/#{status}", status)

  status_filter = Data::Status.parse?(status)
  slang "tested/index", "application"
end

get "/tested/*base" do |env|
  # same as "/compiled"
  base = env.params.url["base"] # "http/client/_/wrong"
  ary  = base.split("/")        # ["http", "client", "_", "wrong"]
  if ary.size >= 3 && ary[-2] == "_"
    status_filter = Data::Status.parse?(ary.pop) # "wrong"
    ary.pop                                      # "_"
    base = ary.join("/")                         # "http/client"
  end
  src = "#{base}.cr"

  env.breadcrumbs << Web::Breadcrumb.new("/tested", "test")
  env.breadcrumbs << Web::Breadcrumb.new("/tested/#{base}", src)

  slang "tested/show", "application"
end

private def render_error(env, obj)
  env.response.headers["Content-Type"] = "text/plain; charset=utf-8"
  env.response.status_code = 500
  env.response.puts obj.to_s
end
