/ arg
/ - example    : Models::Example
/ - heuristics : Job::Heuristics

- s      = example
- eid    = "example-#{s.id}"
- lang   = config.highlight_lang
- status = s.compiled
- status = Data::Status::PENDING if heuristics.skip_compile[s.sha1]?
- style  = status.style

- reasons = Hash(Data::Status, String).new
- reasons[Data::Status::GENERAL] = "This is not a crystal code but a general text."
- reasons[Data::Status::PSEUDO]  = "This is a pseudocode."
- reasons[Data::Status::MACRO]   = "This is a macro."
- reasons[Data::Status::RANDOM]  = "This can generate random output or depend on the execution environment."
- reasons[Data::Status::WRONG]   = "This should be wrong. I'll fix this later."
- reasons[Data::Status::PENDING] = "This is hard to classify, so it is PENDING."

div class="alert alert-#{style} #{eid}" role="alert"
  .alert-body
    span class="badge badge-#{style}" = s.seq3
    span class="badge" = s.clue
    - skip = heuristics.skip_compile[s.sha1]?
    - if skip
      span = " pending (reason: #{skip.by})"
    span class="float-right" = "heuristic id=#{s.sha1.inspect}"
    .crystal-code
      == "<pre><code class=#{lang}>#{s.code}</code></pre>"
    - if s.compiled.failure?
      div = "You can skip this example by adding a reason label."
    - if skip
      div = "You can change the reason label."
    - if ! s.compiled.success?
      table.table.table-borderless.table-xs.table-compact.pl-4.ml-4
        - reasons.each do |reason, help|
          - value = reason.to_s.sub(/^.*::/, "").downcase
          - style = (skip.try(&.by) == value) ? "success" : "primary"
          tr
            td
              a class="btn btn-#{style} btn-xs btn-focus" href="#" role="button" onclick="window.CE_ajax('/heuristic/compile/#{s.id}/#{value}', '.#{eid}');return false" = "Mark as #{value.upcase}"
            td = help
        - if skip || s.compiled.pending?
          tr
            td
              a class="btn btn-danger btn-xs btn-focus" href="#" role="button" onclick="window.CE_ajax('/heuristic/compile/#{s.id}', '.#{eid}', 'DELETE');return false" = "Delete LABEL"
            td = "Stop to skip. This example will be compiled again."
