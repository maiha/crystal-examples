require "./spec_helper"

describe Job::CompileErrorParser do
  sample_code = <<-EOF
    # EXAMPLE_SEQ=1
    foo
    # EXAMPLE_SEQ=2
    bar
    # EXAMPLE_SEQ=3
    EOF

  it "parses line_number, error_seq, success_seqs" do
    log = "Syntax error in tmp/http/client/all.cr:4: expecting ..."

    parser = Job::CompileErrorParser.new(log, sample_code)
    parser.line_number.should eq(4)
    parser.error_seq.should eq(2)
    parser.success_seqs.should eq(1..1)
    parser.error_type.should eq(Job::CompileErrorParser::Error::SYNTAX_ERROR)
  end
    
  it "detect undefined constant" do
    log = "Error in tmp/http/cookie/all.cr:3: undefined constant HTTP::Request"

    parser = Job::CompileErrorParser.new(log, sample_code)
    parser.error_type.should eq(Job::CompileErrorParser::Error::UNDEFINED_CONSTANT)
  end
end
