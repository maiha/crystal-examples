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

  # Sort and compare instance variables. However, except when the expected string is not sorted.
  # This is because json_unmapped and others intentionally order variables.
  # ```
  # A(@json_unmapped={\"b\" => 2_i64}, @a=1)
  # ```
  class ExpectInspectEqual < BaseBuilder(NamedTuple(code: String, eq: String))
    def build : String
      if __sort_ivars__(data["eq"]) == data["eq"]
        "( __sort_ivars__(__demodulize__(( %s ).inspect)) ).should eq( \"%s\" )" % [data["code"], data["eq"]]
      else
        "( __demodulize__(( %s ).inspect) ).should eq( \"%s\" )" % [data["code"], data["eq"]]
      end
    end
  end
end
