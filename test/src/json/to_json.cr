# Converter to be used with `JSON::Serializable`
# to serialize the elements of an `Array(T)` with the custom converter.
#
# ```
# require "json"
#
# class TimestampArray
#   include JSON::Serializable
#
#   @[JSON::Field(converter: JSON::ArrayConverter(Time::EpochConverter))]
#   property dates : Array(Time)
# end
#
# timestamp = TimestampArray.from_json(%({"dates":[1459859781,1567628762]}))
# timestamp.dates   # => [2016-04-05 12:36:21 UTC, 2019-09-04 20:26:02 UTC]
# timestamp.to_json # => %({"dates":[1459859781,1567628762]})
# ```
#
# `JSON::ArrayConverter.new` should be used if the nested converter is also an
# instance instead of a type.
#
# ```
# require "json"
#
# class TimestampArray
#   include JSON::Serializable
#
#   @[JSON::Field(converter: JSON::ArrayConverter.new(Time::Format.new("%b %-d, %Y")))]
#   property dates : Array(Time)
# end
#
# timestamp = TimestampArray.from_json(%({"dates":["Apr 5, 2016","Sep 4, 2019"]}))
# timestamp.dates   # => [2016-04-05 00:00:00 UTC, 2019-09-04 00:00:00 UTC]
# timestamp.to_json # => %({"dates":["Apr 5, 2016","Sep 4, 2019"]})
# ```
#
# This implies that `JSON::ArrayConverter(T)` and
# `JSON::ArrayConverter(T.class).new(T)` perform the same serializations.
