abstract class Cmds::Cmd
  var config : Data::Config
  var require_config = true

  var sse_io = Data::SSE.new(STDOUT)

  protected def sse(*args, **opts)
    return unless config.sse?
    sse_io.send(*args, **opts)
  end
end
