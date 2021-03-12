class Data::Wizard
  include Models
  
  getter config

  record Table, name : String, count : Int32, exists : Bool, schema : String

  # IO
  var try_sources = Try(Array(Models::Source)).try { Models::Source.where("count > 0 OR error <> ''") }
  var try_examples        : Failure(Array(Example)) | Success(Array(Example)) = Models::Example.try
  var try_light_examples  : Failure(Array(Example)) | Success(Array(Example)) = Models::Example.try_light
  var try_extract_counts  : Failure(Hash(Status, Int64)) | Success(Hash(Status, Int64)) = Try(Hash(Status, Int64)).try { Models::Source.count_by_extract }
  var try_compiled_counts : Failure(Hash(Status, Int64)) | Success(Hash(Status, Int64)) = Try(Hash(Status, Int64)).try { Models::Example.count_by_compiled }
  var try_tested_counts   : Failure(Hash(Status, Int64)) | Success(Hash(Status, Int64)) = Try(Hash(Status, Int64)).try { Models::Example.count_by_tested }

  # common data
  var sources  : Array(Models::Source)  = try_sources.get?  || Array(Models::Source).new
  var examples : Array(Models::Example) = try_examples.get? || Array(Models::Example).new
  var examples : Array(Models::Example) = try_examples.get? || Array(Models::Example).new

  var extracted_pct : Int32 = build_extracted_pct
  var compiled_pct  : Int32 = build_compiled_pct
  var tested_pct    : Int32 = build_tested_pct
  var tables : Array(Table) = build_tables

  var compact_compiled_counts = Models::Example.compact_compiled_counts
  var compact_tested_counts   = Models::Example.compact_tested_counts
  
  var extract_counts : Hash(Status, Int64) = try_extract_counts.get? || Hash(Status, Int64).new
  var compiled_counts : Hash(Status, Int64) = try_compiled_counts.get? || Hash(Status, Int64).new
  var tested_counts  : Hash(Status, Int64) = try_tested_counts.get?    || Hash(Status, Int64).new
  var light_examples : Array(Models::Example) = try_light_examples.get? || Array(Models::Example).new

  var fully_extracted : Bool = try_extracted.success?
  var fully_compiled  : Bool = try_compiled.success?
  var fully_tested    : Bool = try_tested.success?
  
  # 1. config
  var sample1 : String = config.crystal_src_dir?.try{|i| File.join(i, "array.cr")} || "(nil)"
  var valid1  : Bool   = File.exists?(sample1)
  var css1    : String = valid1 ? "success" : "danger"
  var alert1  : String = valid1 ? "alert-success" : "alert-danger"

  # 2. database
  var valid2  : Bool   = tables.any? && (tables.count(&.exists) == tables.size)
  var css2    : String = valid2 ? "passed" : "failed"
  var alert2  : String = valid2 ? "alert-success" : "alert-secondary"

  # 3. extract
  var try3    : Failure(Bool) | Success(Bool) = try_extracted
  var cnt3    : Int32  = sources.size
  var pct3    : Int32  = extracted_pct
  var counts3 : Hash(Status, Int64) = extract_counts
  
  var valid3  : Bool   = fully_extracted? && (counts3[Data::Status::FAILURE]? || 0) == 0
  var css3    : String = valid3 ? "passed" : "failed"
  var alert3  : String = valid3 ? "alert-success" : ((pct3 == 0) ? "alert-secondary" : "alert-danger")
  
  # 4. compile
  var cnt4    : Int64  = compact_compiled_counts.values.sum
  var pct4    : Int32  = compiled_pct

  var valid4  : Bool   = (pct4 == 100) && (cnt4 > 0) && compact_compiled_counts.keys.all?(&.ok?)
  var css4    : String = valid4 ? "passed" : "failed"
  var alert4  : String = valid4 ? "alert-success" : ((pct4 == 0) ? "alert-secondary" : ((compact_compiled_counts.keys.max > Data::Status::PENDING) ? "alert-danger" : "alert-warning") )

  # 5. test
  var cnt5    : Int64  = tested_counts.values.sum
  var pct5    : Int32  = tested_pct
  var ok5     : Int64  = tested_counts[Status::SUCCESS]? || 0_i64
  var pd5     : Int64  = tested_counts[Status::PENDING]? || 0_i64
  var er5     : Int64  = tested_counts[Status::ERROR]?   || 0_i64
  var ng5     : Int64  = tested_counts[Status::FAILURE]? || 0_i64
  var un5     : Int64  = tested_counts[Status::UNKNOWN]? || 0_i64

  var valid5  : Bool   = (pct5 == 100) && (cnt5 > 0) && compact_tested_counts.keys.all?(&.ok?)
  var css5    : String = valid5 ? "passed" : "failed"
  var alert5  : String = valid5 ? "alert-success" : ((pct5 == 0) ? "alert-secondary" : "alert-danger")

  def initialize(@config : Config = Config.current)
  end

  ######################################################################
  ### helper methods

  def noteworthy_step : String
    valids = [valid1, valid2, valid3, valid4, valid5]
    valids.each_with_index do |ok, i|
      return "step#{i+1}" if !ok
    end
    return "step5"
  end

  ######################################################################
  ### testing methods

  class NotReady < Exception
  end

  # returns Try(true) or raises the reason within Try
  def try_extracted : Failure(Bool) | Success(Bool)
    Try(Bool).try {
      raise NotReady.new("No examples found.") if light_examples.empty?
      raise NotReady.new("It has not been fully extracted. (#{extracted_pct}%)") if extracted_pct != 100
      true
    }
  end

  def try_compiled : Failure(Bool) | Success(Bool)
    Try(Bool).try {
      raise NotReady.new("No examples found. Extract first.") if compiled_counts.empty?
      raise NotReady.new("It has not been fully compiled. (#{compiled_pct}%)") if compiled_pct != 100
      true
    }
  end

  def try_tested : Failure(Bool) | Success(Bool)
    Try(Bool).try {
      raise NotReady.new("It has not been fully tested. (#{tested_pct}%)") if tested_pct != 100
      true
    }
  end

  ######################################################################
  ### Variable builders

  private def build_extracted_pct : Int32
    total = sources.size
    done  = total - sources.count(&.extract.unknown?)

    if total == 0
      return 0
    else
      return ((done * 100.0) / total).trunc.to_i
    end
  end
  
  private def build_compiled_pct : Int32
    if compiled_counts.empty?
      return 0
    else
      total = compiled_counts.values.sum
      if total == 0
        return 0
      else
        unknown = compiled_counts[Data::Status::UNKNOWN]? || 0
        return (((total - unknown) * 100.0) / total).trunc.to_i
      end
    end
  end

  private def build_tested_pct : Int32
    if tested_counts.empty?
      return 0
    else
      total = tested_counts.values.sum
      if total == 0
        return 0
      else
        unknown = tested_counts[Data::Status::UNKNOWN]? || 0
        return (((total - unknown) * 100.0) / total).trunc.to_i
      end
    end
  end
  
  private def build_tables : Array(Table)
    tables = Array(Table).new
    found  = Models::Source.adapter.tables rescue Array(String).new
    {% begin %}
    {% for k in Pon::Model.subclasses %}
      name   = {{k.id}}.table_name
      count  = {{k.id}}.count rescue -1
      exists = found.includes?(name)
      schema = {{k.id}}.to_s.sub(/^.*\(/,"").chomp(")")
      tables << Table.new(name: name, count: count, exists: exists, schema: schema)
    {% end %}
    {% end %}
    return tables
  end
end
