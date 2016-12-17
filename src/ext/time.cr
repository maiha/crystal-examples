# Backward compatibility for `Time.parse` to pass following code.

# wrong number of arguments for 'Time.parse' (given 2, expected 3)
# Overloads are:
# - Time.parse(time : String, pattern : String, location : Location)
# 
# Time.parse("2017-03-01 00:00:00", "%F %T")
#      ^~~~~

def Time.parse(value : String, fmt : String)
  Pretty.parse(value)
end
