# application
get_with_cache "/public/main.js"
get_with_cache "/public/main.css"

# highlight
get "/public/highlight.css" do |env|
  env.response.headers["Content-Type"] = "text/css"
  slang "public/highlight"
end
