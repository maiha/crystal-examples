class CommentSpec
  ######################################################################
  ### Modify
  class ExpectClass # < BaseBuilder(NamedTuple(code: String, eq: String))
    def build : String
      "( __demodulize__(( %s ).class.to_s) ).should eq( \"%s\" )" % [data["code"], data["eq"]]
    end
  end

  class ExpectTryFloat # < BaseBuilder(NamedTuple(code: String, eq: String))
    def build : String
      "( %s ).to_s.should eq( \"%s\" )" % [data["code"], data["eq"]]
    end
  end

  ######################################################################
  ### Add
  class ExpectNaN < BaseBuilder(NamedTuple(code: String))
    def build : String
      "( %s ).try(&.nan?).should be_true" % [data["code"]]
    end
  end

  class ExpectInspectEqual < BaseBuilder(NamedTuple(code: String, eq: String))
    def build : String
      "( __demodulize__(( %s ).inspect) ).should eq( \"%s\" )" % [data["code"], data["eq"]]
    end
  end
end
