get "/db" do |env|
  env.breadcrumbs << Web::Breadcrumb.new("/db", name: "db")

  slang "db/index", "application"
end

get "/db/:table" do |env|
  name = env.params.url["table"]

  env.breadcrumbs << Web::Breadcrumb.new("/db", name: "db")
  env.breadcrumbs << Web::Breadcrumb.new("/db/#{name}", name: name)

  {% begin %}
  case name
  {% for k in Pon::Model.subclasses %}
  when {{k.id}}.table_name
    klass = {{k.id}}
    slang "db/table", "application"
  {% end %}
  else
    content = "table not found: #{name}"
    slang "layouts/application"
  end
  {% end %}
end

private def grouping_column?(klass) : String?
  case klass.new
  when Models::Heuristic
    "action"
  when Models::Example
    "src"
  else
    nil
  end
end
