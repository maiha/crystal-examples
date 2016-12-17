# The source target that consists of three pieces of information
# 1. `path` is a path of this target file
# 2. `snippets` are chunks of the example codes
# 3. `src` represents the original path of crystal source like 'array.cr'
class Job::Target
  # data
  var path     : String
  var examples : Array(Models::Example)
  var src      : String

  # cache
  var sha1 : String = Data::Source.sha1(File.read(path))
  
  def initialize(@path, @examples, @src)
  end

  # returns a string of examples statuses as follows
  # "array.cr: 119 successes, 0 failures, 0 errors, 1 pending"
  def summarize_status_about : String
    counts = Hash(Data::Status, Int32).new { 0 }
    examples.each do |example|
      counts[yield(example)] += 1
    end
    msg = String.build{|s|
      counts.each do |status, cnt|
        s << "%d %s," % [cnt, status.to_s.downcase]
      end
    }.chomp(",")
    
    "%s: %s" % [@src, msg]
  end
end
