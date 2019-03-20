class Models::Example < Pon::Model
  alias Status = Data::Status

  adapter sqlite
  table_name examples

  field src      : String  # => "array.cr"
  field seq      : Int32   # => 2 (nth example in the src)
  field line     : Int32   # => 21 (line number in the src)
  field type     : String  # => "crystal", "json" (comment block type)
  field code     : String  # content of the comment block
  field sha1     : String = Data::Source.sha1(code?.to_s)
  field compiled : Status = Status::UNKNOWN
  field tested   : Status = Status::UNKNOWN

  def clue : String
    (seq > 0) ? "#{src}:#{line}" : src
  end

  def code=(v : String)
    @code = v
    self.sha1 = Data::Source.sha1(v)
  end
  
  def seq3 : String
    "%03d" % seq
  end

  ######################################################################
  ### Accessor

  def crystal?
    @type.to_s == "" || @type.to_s == "crystal"
  end

  def require_code? : String?
    case code
    when /\A([^\n]*require.*?)\n/
      return $1
    else
      nil
    end
  end
  
  def codes : Array(String)
    buf = code.to_s.strip
    buf.empty? ? Array(String).new : buf.split(/\n/)
  end

  def delete_compile_heuristic!
    # 1. delete heuristic
    Models::Heuristic.skip_compile?(sha1).try(&.delete)
    # 2. clear compile caches
    CompileCache.delete(self)
    # 3. change compiled status to unknown
    self.compiled = Status::UNKNOWN
    save!
  end

  def delete_test_heuristic!
    # 1. delete heuristic
    Models::Heuristic.skip_test?(sha1).try(&.delete)
    # 2. clear test caches
    TestCache.delete(self)
    # 3. change tested status to unknown
    self.tested = Status::UNKNOWN
    save!
  end

  ######################################################################
  ### Query

  def self.update_all(sql : String)
    a = adapter
    a.exec "UPDATE #{a.qt} SET #{sql}"
  end

  def self.compact_compiled_counts : Hash(Status, Int64)
    hash = Hash(Status, Int64).new
    count_by_compiled.each do |key, val|
      status = Status.from_value((key.value / 100) * 100)
      hash[status] = (hash[status]? || 0_i64) + val
    end
    hash
  end    

  def self.compact_tested_counts : Hash(Status, Int64)
    hash = Hash(Status, Int64).new
    count_by_tested.each do |key, val|
      status = Status.from_value((key.value / 100) * 100)
      hash[status] = (hash[status]? || 0_i64) + val
    end
    hash
  end    

  def self.try : Try(Array(Example))
    Try(Array(Example)).try {
      all("ORDER BY src, seq")
    }
  end

  def self.try_light : Try(Array(Example))
    Try(Array(Example)).try {
      Models::Example.all(["src", "seq", "compiled", "tested"], "ORDER BY src,seq")
    }
  end

  ######################################################################
  ### Conversions

  def to_source
    String.build do |io|
      io << "  # ```#{type?}\n"
      io << code.gsub(/^/, "  #")
    end
  end
end
