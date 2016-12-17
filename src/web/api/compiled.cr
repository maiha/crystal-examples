get "/compiled" do |env|
  env.breadcrumbs << Web::Breadcrumb.new("/compiled", "compiled")

  status_filter = nil
  slang "compiled/index", "application"
end

get "/compiled/_/:status" do |env|
  status = env.params.url["status"]

  env.breadcrumbs << Web::Breadcrumb.new("/compiled", "compiled")
  env.breadcrumbs << Web::Breadcrumb.new("/compiled/_/#{status}", status)

  status_filter = Data::Status.parse?(status)
  slang "compiled/index", "application"
end

get "/compiled/*base" do |env|
  base = env.params.url["base"] # "http/client/_/wrong"
  ary  = base.split("/")        # ["http", "client", "_", "wrong"]
  if ary.size >= 3 && ary[-2] == "_"
    status_filter = Data::Status.parse?(ary.pop) # "wrong"
    ary.pop                                      # "_"
    base = ary.join("/")                         # "http/client"
  end
  src = "#{base}.cr"

  env.breadcrumbs << Web::Breadcrumb.new("/compiled", "compiled")
  env.breadcrumbs << Web::Breadcrumb.new("/compiled/#{base}", src)

  slang "compiled/show", "application"
end

private def render_error(env, obj)
  env.response.headers["Content-Type"] = "text/plain; charset=utf-8"
  env.response.status_code = 500
  env.response.puts obj.to_s
end
