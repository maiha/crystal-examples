class Models::CompileCache < Pon::Model
  enum Error
    NOT_FOUND
    SYNTAX_ERROR
    UNDEFINED_CONSTANT
    UNKNOWN_ERROR
  end

  adapter sqlite
  table_name compile_caches
  
  field src         : String
  field seq         : Int32
  field exit_code   : Int32  = -1   # exit status
  field log         : String = ""
  field error_type  : Error = Error::NOT_FOUND
  field error_value : String = ""   # general purpose container for error
  field started_at  : Time
  field stopped_at  : Time

  # true when compilation has been succeeded
  def success? : Bool
    exit_code == 0
  end

  def human_duration : String
    "%.1fs" % duration?.try(&.total_seconds) rescue "T/O"
  end
  
  def duration? : Time::Span?
    if (t1 = started_at) && (t2 = stopped_at)
      t2 - t1
    else
      nil
    end
  end

  def start!
    @exit_code   = -1
    @log         = ""
    @error_type  = Error::NOT_FOUND
    @error_value = ""
    @started_at  = Time.now
    @stopped_at  = nil
    save!
  end

  def stop!
    @stopped_at = Time.now
    save!
  end

  def self.from(src : String)
    seq = 0
    query = "WHERE src = '#{src}' AND seq = #{seq}"
    return all(query).first? || new(src: src, seq: seq)
  end

  def self.delete(example : Example)
    qt = adapter.qt
    adapter.exec "DELETE FROM #{qt} WHERE src = ? AND (seq = 0 OR seq = ?)", [example.src, example.seq]
  end

  def self.human_durations_hash : Hash(String, String)
    hash = Hash(String, String).new
    all(["src", "started_at", "stopped_at"]).each do |cache|
      hash[cache.src] = cache.human_duration
    end
    hash
  rescue
    Hash(String, String).new
  end
end
