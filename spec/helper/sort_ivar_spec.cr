require "./spec_helper"

describe "__sort_ivars__" do
  it "sorts @foo and @bar alphabetically." do
    __sort_ivars__("Foo(@foo = 1, @bar = 2)").should eq("Foo(@bar = 2, @foo = 1)")
  end
end
