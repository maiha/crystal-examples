module Data::Errors
  module Parsing
    abstract def path : String
    abstract def comments : Array(Comment)
  end

  class UnexpectedEnd < Exception
    include Parsing
    property path     : String
    property line_no  : Int32
    property line     : String
    property current  : Comment
    property comments : Array(Comment)
    
    def initialize(@path, @line_no, @line, @current, @comments)
      msg = String.build do |s|
        s << "#{path}:#{line_no}: unexpected example end\n"
        s << current.source
        s << line
      end
      super(msg)
    end
  end
end
