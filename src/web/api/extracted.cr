get "/extracted" do |env|
  env.breadcrumbs << Web::Breadcrumb.new("/extracted", "extracted")

  slang "extracted/index", "application"
end
