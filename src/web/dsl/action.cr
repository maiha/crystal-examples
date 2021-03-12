######################################################################
### global macros

macro controller_name
  env.params.url.to_s.split("/").first
end

macro param(name)
  env.params.url["{{name.id}}"].split(".",2).first.not_nil!
end

macro param?(name)
  env.params.url["{{name.id}}"]?.try(&.split(".",2).first.not_nil!)
end

macro param_i(name)
  param({{name}}).to_i32
end

macro param_i?(name)
  Try(Int32).try{ param({{name}}).to_i32 }.get?
end

macro post_data(name)
  env.params.body["{{name.id}}"]
end

macro post_data?(name)
  Try(String).try{ post_data({{name}}).to_s.tap{|v| raise v if v.empty?} }.get?
end

macro post_data_i(name)
  post_data({{name}}).to_i32
end

macro post_data_i?(name)
  Try(Int32).try{ post_data({{name}}).to_i32 }.get?
end

macro ext?(name)
  Try(String).try { env.params.url["{{name.id}}"].split(".",2)[1] }.get?
end

macro get_with_cache(name)
  CACHE{{name.gsub(/[\/\.]/, "_").upcase.id}} = render "#{__DIR__}/../views{{name.id}}.ecr"
  get {{name}} do |env|
    env.response.headers["Content-Type"] = MIME.from_filename({{name}})
    CACHE{{name.gsub(/[\/\.]/, "_").upcase.id}}
  end
end

macro slang(name)
  config = Data::Config.current
  render "#{__DIR__}/../views/{{name.id}}.slang"
end

macro slang(name, layout)
  config = Data::Config.current
  if env.request.headers["X-PJAX"]? || env.params.url["_pjax"]?
    slang({{name}})
  else
    render "#{__DIR__}/../views/{{name.id}}.slang", "#{__DIR__}/../views/layouts/{{layout.id}}.slang"
  end
end

######################################################################
### global functions

def render_json(env)
  env.response.headers["Content-Type"] = "application/json; charset=utf-8"
  yield.to_json
rescue err
  env.response.headers["Content-Type"] = "text/plain; charset=utf-8"
  env.response.status_code = 500
  env.response.puts err.to_s
end
