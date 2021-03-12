# General purpose status
# Many models and data use subset of this status.
# Scope validations belong to those users.

enum Data::Status
  UNKNOWN = 0
  SUCCESS = 200
  PENDING = 300
  GENERAL = 301 # pending by GENERAL information
  PSEUDO  = 302 # pending by PSEUDO code
  MACRO   = 303 # pending by MACRO code
  WRONG   = 304 # pending by WRONG code
  RANDOM  = 305 # pending by RANDOM output
  ERROR   = 400
  FAILURE = 500

  def floor : Status
    self.class.from_value(((value / 100) * 100).to_i)
  end

  def ok?
    (UNKNOWN < self) && (self < ERROR)
  end
  
  def err?
    ERROR <= self
  end
  
  def style : String
    styles = {
      0 => "secondary",
      2 => "success",
      3 => "primary",
      4 => "warning",
      5 => "danger",
    }
    return styles[value / 100]? || "danger"
  end
end
