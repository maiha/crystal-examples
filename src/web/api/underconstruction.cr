######################################################################
### Testing : not production

# "^/sse/" is mark for Nginx setting for EventSource
get "/sse/test" do |env|
  env.response.headers["Content-Type"]      = "text/event-stream;"
  env.response.headers["Content-Encoding"]  = "none;"
  env.response.headers["Cache-Control"]     = "no-cache;"
  env.response.headers["X-Accel-Buffering"] = "no;"
  
  sse = Data::SSE.new(env.response)
  100.times do |i|
    sse.send(event: "test", data: i)
    sleep 1
  end
end

# "^/ws/" is mark for Nginx setting for WebSocket
SOCKETS = [] of HTTP::WebSocket
ws "/ws/test.ws" do |socket|
  # Add the client to SOCKETS list
  SOCKETS << socket

  100.times do |i|
    # SOCKETS.each { |socket| socket.send i.to_s}
    socket.send(i.to_s)
    sleep 1
  end

  # Remove clients from the list when it's closed
  socket.on_close do
    SOCKETS.delete socket
  end
end
