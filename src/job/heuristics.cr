class Job::Heuristics
  alias PATH = String
  
  var heuristics : Array(Models::Heuristic)

  var requires     = Hash(PATH, Models::Heuristic).new
  var skip_compile = Hash(Data::SHA1, Models::Heuristic).new
  var skip_test    = Hash(Data::SHA1, Models::Heuristic).new

  def initialize(heuristics : Array(Models::Heuristic)? = nil)
    @heuristics = heuristics || Models::Heuristic.all
    heuristics().each do |h|
      case h.action
      when Models::Heuristic::ACTION_REQUIRE
        requires[h.target] = h
      when Models::Heuristic::ACTION_COMPILE
        skip_compile[h.target] = h
      when Models::Heuristic::ACTION_TEST
        skip_test[h.target] = h
      else
        raise "[BUG] heuristic contains unknown action: #{h.inspect}"
      end
    end
  end
end
