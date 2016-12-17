- icon = config.web_step3_icon.gsub(/fa-\dx/, "")
- try  = wiz.try_sources
- pct  = wiz.pct3
- css  = wiz.css3
- cnt  = wiz.cnt3

- if err = wiz.try3.err?
  div class="alert alert-warning" role="alert"
    h4 class="alert-heading" = err.to_s

- if src_dir = config.crystal_src_dir?
  .job-operations
    .card.card-sm.border-secondary
      .card-header
        a.pjax pjax_push="false" method="POST" class="btn btn-primary btn-sm btn-focus" href="/job/extract/run" role="button" = "Extract examples"
      .card-body
        == "Parse <code>'#{src_dir}/**/*.cr'</code> again. (several seconds)"
  .m-2

div#step3 class="alert #{wiz.alert3}" role="alert"
  h5 class="alert-heading" = "Extracted : #{pct}%"

  / .stats-graph
  /   span.stats.job-pct-bar style="width: #{pct}%;"
  /   i class=icon style="margin-top:-10px;"

  .stats-box.pretty-box
    span = "#{cnt} files"
    == tag_badges(wiz.extract_counts).join("\n")
    div.float-right
      a.pjax href="/extracted" class="btn btn-success btn-xs btn-focus" = "See detail"
  
  // .stats-graph
  //    span.stats style="width: #{ok_width}%; background-color:green;"
  //    span.stats style="width: #{ng_width}%; background-color:#db4545;"

  - if sources = try.get?
    ul class="list-group list-group-flush setting-list-group"
    - sources.each do |src|
      - if error = src.error?
        li class="list-group-item"
          span class="badge badge-#{src.extract.style}" = src.path
          .crystal-code
            == "<pre><code>#{error.chomp}</code></pre>"

  hr
