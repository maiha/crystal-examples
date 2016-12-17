- wiz = Data::Wizard.new
- try = wiz.try_sources
- css = wiz.css3
- cnt = wiz.cnt3
- pct = wiz.pct3

== slang "layouts/_breadcrumb"

- if msg = try.err?.try(&.message)
  span class="badge badge-danger" = msg

.m-2

div class="alert #{wiz.alert3}" role="alert"
  h5 class="alert-heading"
    i class="fas fa-database"
    span class=css = "Extracted [#{pct}%]"
    span = "#{cnt} files"
  .alert-body
    == tag_badges(wiz.extract_counts).join("\n")

/ .stats-graph
/    span.stats style="width: #{okp}%; background-color:green;"
/    span.stats style="width: #{ngp}%; background-color:#db4545;"

.m-2
div
  - if sources = try.get?
    table#stats-table.pretty-table class="table tabls-sm"
      thead.thead-light
        tr
          th = "file"
          th = "examples"
          th = ""
      tbody
        - sources.each do |src|
          - path_css  = src.extract.style
          - count_css = (src.count > 0) ? "passed" : ""
          - err_id    = "err#{src.id}"
          tr
            td.path  class=path_css  = src.path
            td.count class=count_css = src.count
            td.error
              - if src.error?
                a class="badge badge-danger btn-focus" data-toggle="collapse" href="##{err_id}" role="button" aria-expanded="false" aria-controls="#{err_id}"
                  = src.error?.to_s.split(/\n/, 2).first
          - if err = src.error?
            tr
              td colspan=3
                div.collapse.crystal-code id=err_id
                  == "<pre><code>#{err.chomp}</code></pre>"
