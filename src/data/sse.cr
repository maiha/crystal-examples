class Data::SSE
  def initialize(@io : IO)
  end

  def send(event : String, data : String, id : String? = nil)
    event = String.build do |s|
      s << "event: #{event}\n"
      s << "data: #{data}\n"
      s << "id: #{id}\n" if id
      s << "\n"
    end
    @io.puts event
    @io.flush
  end

  def send(event : String, data, id : String? = nil)
    data = data.to_json.gsub(/\n/, "")
    send(event, data, id)
  end
end
