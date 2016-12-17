/ arg
/ - example    : Models::Example
/ - heuristics : Job::Heuristics

- s      = example
- eid    = "example-#{s.id}"
- lang   = config.highlight_lang
- status = (heuristics.skip_test[s.sha1]? || heuristics.skip_compile[s.sha1]?).try(&.status?) || s.tested
- style  = status.style

- reasons = Hash(Data::Status, String).new
- reasons[Data::Status::GENERAL] = "This is not a crystal code but a general text."
- reasons[Data::Status::PSEUDO]  = "This is a pseudocode."
- reasons[Data::Status::MACRO]   = "This is a macro."
- reasons[Data::Status::RANDOM]  = "This provides random output."
- reasons[Data::Status::WRONG]   = "This should be wrong. I'll fix this later."
- reasons[Data::Status::PENDING] = "This can't be fixed immediately."

div class="alert alert-#{style} #{eid}" role="alert"
  .alert-body
    span class="badge badge-#{style}" = s.seq3
    span class="badge" = s.clue
    - skip = heuristics.skip_test[s.sha1]?
    - if skip
      span = " pending (reason: #{skip.by})"
    .crystal-code
      == "<pre><code class=#{lang}>#{s.code}</code></pre>"
    - if s.tested.failure?
      div = "You can skip this example by adding a reason label."
    - if skip
      div = "You can change the reason label."
    - if ! s.tested.success?
      table.table.table-borderless.table-xs.table-compact.pl-4.ml-4
        - reasons.each do |reason, help|
          - value = reason.to_s.sub(/^.*::/, "").downcase
          - style = (skip.try(&.by) == value) ? "success" : "primary"
          tr
            td
              a class="btn btn-#{style} btn-xs btn-focus" href="#" role="button" onclick="window.CE_ajax('/heuristic/test/#{s.id}/#{value}', '.#{eid}');return false" = "Mark as #{value.upcase}"
            td = help
        - if skip || s.tested.pending?
          tr
            td
              a class="btn btn-danger btn-xs btn-focus" href="#" role="button" onclick="window.CE_ajax('/heuristic/test/#{s.id}', '.#{eid}', 'DELETE');return false" = "Delete LABEL"
            td = "Stop to skip. This example will be tested again."
