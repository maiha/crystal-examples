require "./spec_helper"

describe Job::TestPassedParser do
  it "parses success_seqs when TEST_PASSED_SEQ found" do
    log = <<-EOF
      TEST_PASSED_SEQ=1
      a b cTEST_PASSED_SEQ=2
      xxx
      EOF

    parser = Job::TestPassedParser.new(log)
    parser.success_seqs.should eq(1..2)
  end

  it "raises nothing passed when not found" do
    log = <<-EOF
      a b c
      xxx
      EOF

    parser = Job::TestPassedParser.new(log)
    expect_raises(Exception, /nothing passed/i) do
      parser.success_seqs.should eq(1..2)
    end
  end
end
