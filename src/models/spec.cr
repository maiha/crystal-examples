class Models::Spec < Pon::Model
  alias Status = Data::Status

  adapter sqlite
  table_name specs
  
  field src    : String         # "array.cr"
  field seq    : Int32          # 0: all, 1-n: nth example
  field line   : Int32          # 13
  field code   : String         # "require ..."
  field sha1   : String = Data::Source.sha1(code?.to_s)
  field status : Status = Status::UNKNOWN
end
