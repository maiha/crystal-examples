class Job::TestPassedParser
  alias Seqs = Range(Int32, Int32)

  var try_success_seqs : Try(Seqs)  = parse_success_seqs
  
  def initialize(@buf : String)
    parse
  end
  
  def parse : Try(Seqs)
    try_success_seqs
  end
  
  def success_seqs? : Seqs?
    try_success_seqs.get?
  end
  
  def success_seqs : Seqs
    try_success_seqs.get
  end
  
  private def parse_success_seqs : Try(Seqs)
    Try(Seqs).try {
      seq = 0
      @buf.scan(/#{Generate::TEST_PASSED_SEQ_MARK}(\d+)/) do
        seq = $1.to_i32
      end
      seqs = 1..seq
      seqs.any? || raise "Nothing passed"
      seqs
    }
  end
end
