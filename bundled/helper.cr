def __time__(s)
  FUNC_TIME.parse(s)
end

module FUNC_TIME
  MONTH_NAMES = %w(January February March April May June July August September October
November December)
  SHORT_MONTH_NAMES = MONTH_NAMES.map(&.[0..2])

  def self.parse(value : String) : ::Time
    utc = location = ::Time::Location::UTC
    case value
    when /\A\d{4}-\d{2}-\d{2}([ T])\d{2}:\d{2}:\d{2}( ?)[+-]\d{2}(:?)\d{2}/
      ::Time.parse(value, "%F#{$1}%T#{$2}%#{$3}z", location)
    when /\A\d{4}-\d{2}-\d{2}([ T])\d{2}:\d{2}:\d{2}\.\d{1,3}( ?)\+\d{2}(:?)\d{2}/
      ::Time.parse(value, "%F#{$1}%T.%L#{$2}%#{$3}z", location)
    when /\A\d{4}-\d{2}-\d{2}([ T])\d{2}:\d{2}:\d{2}\.\d{3}(Z?)/
      location = utc if $2.to_s != ""
      ::Time.parse(value, "%F#{$1}%T.%L", location)
    when /\A\d{4}-\d{2}-\d{2}([ T])\d{2}:\d{2}:\d{2}(Z?)/
      location = utc if $2.to_s != ""
      ::Time.parse(value, "%F#{$1}%T", location)
    when /\A(\d{4}-\d{2}-\d{2})\Z/
      ::Time.parse(value, "%F", location)
    when /\A(?<year>\d{4})[-: \/]?(?<month>\d{2})[-: \/]?(?<day>\d{2})[-: ]?(?<hour>\d{2})[-: ]?(?<min>\d{2})[-: ]?(?<sec>\d{2})?\Z/
      ::Time.local($~["year"].to_i, $~["month"].to_i, $~["day"].to_i, $~["hour"].to_i, $~["min"].to_i,  $~["sec"]?.try(&.to_i) || 0, location: location)

    when /\A([A-Za-z]{3}\s+)?(?<month>[A-Z][a-z]{2,9})\s+(?<day>\d{2})\s+(?<hour>\d{2})[-: ]+(?<min>\d{2})[-: ]+(?<sec>\d{2})(\s+[+-]\d{4})?\s+(?<year>\d{4})\b/
      year = $~["year"].to_i
      v = $~["month"]
      i = MONTH_NAMES.index(v) || SHORT_MONTH_NAMES.index(v) || raise ArgumentError.new("#{v.inspect} seems MONTH, but our dictionary doesn't support it.")
      month = i + 1
      ::Time.local(year, month, $~["day"].to_i, $~["hour"].to_i, $~["min"].to_i,  $~["sec"].to_i, location: location)
    else
      raise "BUG: __time__ cannot parse: #{value.inspect}"
    end
  end
end
