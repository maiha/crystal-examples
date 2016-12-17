record Job::Message,
  topic : String,
  pct   : Int32,                # run: 0..99, done: 100, halt: -1
  data  : String do

  HALT = -1
  DONE = 100

  def to_json : String
    {
      "topic" => topic,
      "pct"   => pct,
      "data"  => data,
    }.to_json
  end

  def self.halt(topic : String, data : String = "User interrupted")
    new(topic, HALT, data)
  end
end
