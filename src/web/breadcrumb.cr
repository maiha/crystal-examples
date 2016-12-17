record Web::Breadcrumb, path : String, name : String

class HTTP::Server::Context
  var breadcrumbs = Array(Web::Breadcrumb).new
end
