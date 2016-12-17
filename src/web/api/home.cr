get "/" do |env|
  slang "index", "application"
end

get "/favicon.ico" do |env|
  # TODO: no logging
  halt env, 404, "no favicon"
end
