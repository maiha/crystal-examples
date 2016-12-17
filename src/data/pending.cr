# [deprecated] Use `Heuristic` instead.

class Data::Pending_Deprecated
  var reasons = Hash(String, String).new

  delegate size, to: reasons

  def []=(sha1 : String, reason : String)
    case sha1
    when /^[a-f0-9]{40}$/
      reasons[sha1] = reason
    else
      raise "invalid sha1: #{sha1[0,40]}...(#{sha1.size})"
    end
  end

  def []?(comment : Comment) : String?
    sha1 = Source.sha1(comment.code)
    self[sha1]?
  end

  def []?(sha1 : String) : String?
    case sha1
    when /^[a-f0-9]{40}$/
      reasons[sha1]?
    else
      raise "invalid sha1: #{sha1[0,40]}...(#{sha1.size})"
    end
  end
end
