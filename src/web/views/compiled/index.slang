/ - status_filter : Data::Status?

- wiz = Data::Wizard.new
- try = wiz.try_light_examples
- css = wiz.css4
- cnt = wiz.cnt4
- pct = wiz.pct4

- human_durations_hash = Models::CompileCache.human_durations_hash

== slang "layouts/_breadcrumb"

- if err = try.err?
  span class="badge badge-danger" = err.message || err.class

.m-2

div class="alert #{wiz.alert4}" role="alert"
  h5 class="alert-heading"
    // Compiled [100%] 1981 examples
    i class="fas fa-database"
    span class=css = "Compiled [#{pct}%]"
    span = "#{cnt} examples"
  .alert-body
    table
      // compile  1863 success 3 general 43 pseudo 71 macro 1 wrong  94.0%(1863/1981)
      tr
        td.pr-2 = "compile"
        td
          - ok = nil
          - if lights = try.get?
            - grouped = lights.group_by(&.compiled)
            - grouped.keys.sort.each do |status|
              - value = status.to_s.downcase
              - count = grouped[status].size
              - focus = (status == status_filter) ? "btn-focus" : ""
              - style = "badge badge-#{status.floor.style} #{focus}"
              a.pjax href="/compiled/_/#{value}" title=value
                span class=style = "#{count} #{value}"
              - ok = count if status.success?
          - ok ||= 0
        td.pl-2 = "%.1f%%(%d/%d)" % [100.0*ok/cnt, ok, cnt]

.m-2
div
  - if examples = try.get?
    - grouped = examples.group_by(&.src)
    table#stats-table.pretty-table class="table tabls-sm"
      thead.thead-light
        tr
          th = "time"
          th = "file"
          th = "examples"
          th = "compile"
      tbody
        - grouped.each do |src, ary|
          - base = src.sub(/\.cr$/, "")
          - counts = ary.group_by(&.compiled).transform_values(&.size)
          - if status_filter == nil || counts[status_filter]?
            tr
              td.pl-1 = human_durations_hash[src]? || "---"
              td.pl-1
                a.pjax href="/compiled/#{base}" title=src = src
              td.center  = ary.size
              td.compile
                - counts.keys.sort.each do |status|
                  - value = status.to_s.downcase
                  - focus = (status == status_filter) ? "btn-focus" : ""
                  - style = "badge badge-#{status.floor.style} #{focus}"
                  a.pjax href="/compiled/#{base}/_/#{value}" title=value
                    span class=style = "#{counts[status]} #{value}"
