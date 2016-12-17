module Web::Job
  PUBS = [] of ::Job::Worker
  SUBS = [] of HTTP::WebSocket

  @@user_interrupted = false
  
  class Locked < Exception
    var topic : String
  end
  
  def self.pub(msg : ::Job::Message)
    payload = msg.to_json
    SUBS.each(&.send(payload))
  end

  def self.sub(user : HTTP::WebSocket)
    SUBS << user
  end

  def self.unsub(user : HTTP::WebSocket)
    SUBS.delete(user)
  end

  def self.try_start_compiler
    Try(Bool).try {
      config   = Data::Config.current
      examples = Data::Wizard.new(config).examples
      compile  = ::Job::Compile.new(examples, crystal: config.crystal_bin)
      compile.logger = Pon.logger
      run(compile)
    }
  end
  
  def self.try_stop_compiler
    Try(Bool).try {
      stop("compile")
    }
  end
  
  def self.try_start_tester
    config   = Data::Config.current
    examples = Data::Wizard.new(config).examples
    test = ::Job::Test.new(examples, crystal: config.crystal_bin)
    test.logger = Pon.logger
    Try(Bool).try {
      run(test)
    }
  end
  
  def self.try_stop_tester
    Try(Bool).try {
      stop("test")
    }
  end
  
  def self.run(worker : ::Job::Worker) : Bool
    if one = PUBS.first?
      if one.running?
        err = Locked.new
        err.topic = one.topic
        raise err
      end
    end

    PUBS.replace([worker])

    worker.callback = ->(msg : ::Job::Message) {
      pub(msg)
      iterate_next
    }
    
    @@user_interrupted = false
    spawn do
      worker.running = true
      worker.run
      worker.running = false
      PUBS.clear
    end

    return true
  end

  def self.stop(topic : String) : Bool
    return false if PUBS.empty?
    one = PUBS.first
    return false if !one.running?
    return false if one.topic != topic

    @@user_interrupted = true
  end

  def self.iterate_next : Bool
    if @@user_interrupted
      false
    else
      true
    end
  end

  def self.current? : Worker?
    PUBS.first?
  end
end
