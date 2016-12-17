module Data::Errors
  module Parsing
    abstract def path : String
    abstract def comments : Array(Comment)
  end

  class UnexpectedEnd < Exception
    include Parsing
    property path
    property line_no
    property line
    property current
    property comments
    
    def initialize(@path : String, @line_no : Int32, @line : String, @current : Comment, @comments : Array(Comment))
      msg = String.build do |s|
        s << "#{path}:#{line_no}: unexpected example end\n"
        s << current.source
        s << line
      end
      super(msg)
    end
  end
end
