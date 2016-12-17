class Models::Source < Pon::Model
  adapter sqlite
  table_name sources
  
  field path    : String
  field count   : Int32          # the number of examples
  field extract : Data::Status = Data::Status::UNKNOWN
  field error   : String
end
