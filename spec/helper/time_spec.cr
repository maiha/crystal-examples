require "./spec_helper"

describe "__time__" do
  it "parses Time literal" do
    __time__("2016-02-15T04:35:50Z").should eq(Time.utc(2016, 2, 15, 4, 35, 50))
  end
end
