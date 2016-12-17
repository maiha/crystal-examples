Cmds.command "web" do
  ######################################################################
  ### Usage
  
  usage "run 0.0.0.0:3000   # starts web server"

  ######################################################################
  ### Variables
  
  ######################################################################
  ### Tasks

  task "run" do
    host, port = build_host_port(args.first?)
    env = config.web_env? || "development"
    server = Web::Server.new(host, port, env)
    server.start
  end

  def run
    invoke_task(task_name? || "run")
  end
  
  private def build_host_port(v) : {String, Int32}
    case v
    when /^(.*?):(\d+)$/
      host = $1
      port = $2.to_i
    when String
      host = v
    end
    host ||= config.web_host
    port ||= config.web_port
    return {host, port}
  end
end
