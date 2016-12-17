class Job::Finished < Exception
  getter pct
  def initialize(@pct : Int32); end
end
