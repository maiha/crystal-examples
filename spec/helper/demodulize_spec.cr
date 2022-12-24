require "./spec_helper"

describe "__demodulize__" do
  it "strips M_XXX prefix module name" do
    __demodulize__("M__Enum1::M__Enum2::Foo::Bar").should eq("Foo::Bar")
  end

  it "nop when non M-prefixed module name" do
    __demodulize__("Foo::Bar").should eq("Foo::Bar")
  end
end
