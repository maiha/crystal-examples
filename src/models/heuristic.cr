# `Models::Heuristic` keeps heuristic behavior information about
# whether the source code needs to be compiled.
#
# For example, if examples in "digest/base.cr" depend "digest" library,
# it can be represented as follows.
#
# ```crystal
# Heuristic.new(action: "require", target: "digest/base.cr", by: "digest", comment: "comment")
# ```
#
# ```text
# require digest/base.cr by:digest comment:comment
# ```
#
# For another example, if a code should be skipped by some reason like "pending",
# it can be represented as follows with its SHA1.
# Here action is one of "compile" or "test".
#
# ```crystal
# Heuristic.new(action: "compile", target: "9ca1ba7545b5d092ae6f79cd2f8068bed8e65f86", by: "pending", comment: "comment")
# ```
#
# ```text
# compile 9ca1ba7545b5d092ae6f79cd2f8068bed8e65f86 by:pending comment:comment
# ```

class Models::Heuristic < Pon::Model
  adapter sqlite
  table_name heuristics

  field action : String         # "require" or "compile" or "test"
  ACTION_REQUIRE = "require"    # require library
  ACTION_COMPILE = "compile"    # skip to compile with reason
  ACTION_TEST    = "test"       # skip to test with reason

  field target : String         # SHA1 or source path
  # - SHA1 of the code for "skip" action
  # - file path for "require" action

  field by : String = ""        # arg for actions
  # - reason string for pending action : `Data::Status`
  # - the library name for "require" actin

  field comment : String = ""    # comments especially for jnl

  def pending? : Bool
    (action == ACTION_COMPILE) || (action == ACTION_TEST)
  end
  
  def status? : Data::Status?
    pending? ? Data::Status.parse(by) : nil
  end
  
  def status : Data::Status
    Data::Status.parse(by)
  end
  
  def self.skip_compile?(sha1 : String) : Heuristic?
    all("WHERE action = 'compile' AND target = '#{sha1}' limit 1").first?
  end
  
  def self.skip_test?(sha1 : String) : Heuristic?
    all("WHERE action = 'test' AND target = '#{sha1}' limit 1").first?
  end
  
  # register a heuristic to DB where {action, target} are used for primary key.
  def self.register!(action : String, target : String, by : String, comment : String)
    # "skip fcfa1dcfbd742d2971639c62a2e08e9319368901 pseudo array.cr:9"
    # "require http/common.cr http http/common.cr:1"
  
    h = all("WHERE action = '#{action}' AND target = '#{target}' limit 1").first? || new(action: action, target: target)
    h.by = by
    h.comment = comment
    h.save!
  end

  def self.register!(h : Heuristic)
    register!(action: h.action, target: h.target, by: h.by, comment: h.comment)
  end

  def self.clear_cache
    Models::CompileCache
  end
  
  ######################################################################
  ### Serialize (journal text)

  # "require digest/base.cr by:digest comment:digest/base.cr:0"
  # "skip 9ca1ba7545b5d092ae6f79cd2f8068bed8e65f86 by:pending comment:ecr.cr:1"

  def to_jnl : String
    "#{action} #{target} by:#{by} comment:#{comment}"
  end

  def self.try_jnl(line : String) : Failure(Models::Heuristic) | Success(Models::Heuristic)
    Try(Heuristic).try{ from_jnl(line) }
  end

  def self.from_jnl(line : String) : Heuristic
    case line.chomp
    when /\A(.*?)\s+(.*?)\s+by:(.*?)\s+comment:(.*?)\Z/
      new(action: $1, target: $2, by: $3, comment: $4)
    else
      raise ArgumentError.new("invalid jnl: '#{line}'")
    end
  end

  def self.seed!(jnl_data : String? = nil)
    jnl_data ||= Data::Bundled::HEURISTIC_JNL
    delete_all
    adapter.transaction do
      jnl_data.split(/\n/).each do |line|
        next if line.empty?
        next if line.starts_with?("#")
        try = try_jnl(line)
        case try
        when Success
          try.get.save!
        when Failure
          Log.error { try.err?.to_s }
        end
      end
    end
  end

  def self.dump : String
    all("ORDER BY comment").map{|s| "#{s.to_jnl}\n"}.sort.join
  end

  def self.dump!(path : String)
    File.write(path, dump)
  end

  def self.load!(path : String)
    File.exists?(path) || raise "not found: #{path}"
    seed!(File.read(path))
  end

  def to_s(io : IO)
    io << to_jnl
  end
end
