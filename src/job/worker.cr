module Job::Worker
  abstract def run : Nil

  var logger  = Logger.new(STDOUT)
  var running = false
  var callback : Proc(Message, Bool) = ->(msg : Message){ true }

  macro included
    var topic : String = self.class.name.split(/::/)[-1].downcase
  end
end
