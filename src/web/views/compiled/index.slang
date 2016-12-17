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
    i class="fas fa-database"
    span class=css = "Compiled [#{pct}%]"
    span = "#{cnt} examples"
  .alert-body
    table
      tr
        td = "compile "
        td
          - if lights = try.get?
            - grouped = lights.group_by(&.compiled)
            - grouped.keys.sort.each do |status|
              - value = status.to_s.downcase
              - count = grouped[status].size
              - focus = (status == status_filter) ? "btn-focus" : ""
              - style = "badge badge-#{status.floor.style} #{focus}"
              a.pjax href="/compiled/_/#{value}" title=value
                span class=style = "#{count} #{value}"

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
