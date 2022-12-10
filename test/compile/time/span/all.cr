# time/span.cr:1 (001)
# EXAMPLE_SEQ=1
# time/span.cr:1
Time::Span.new(nanoseconds: 10_000)                           # => 00:00:00.000010000
Time::Span.new(hours: 10, minutes: 10, seconds: 10)           # => 10:10:10
Time::Span.new(days: 10, hours: 10, minutes: 10, seconds: 10) # => 10.10:10:10
