class Web::Server
  def initialize(@host : String, @port : Int32, env : String)
    Kemal.config.port = @port
    Kemal.config.env  = env
  end

  def start
    Kemal.run
  end
end
