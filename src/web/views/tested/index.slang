/ - status_filter : Data::Status?

- wiz = Data::Wizard.new
- try = wiz.try_light_examples
- css = wiz.css5
- cnt = wiz.cnt5
- pct = wiz.pct5

- human_durations_hash = Models::TestCache.human_durations_hash

== slang "layouts/_breadcrumb"

- if err = try.err?
  span class="badge badge-danger" = err.message || err.class

.m-2

div class="alert #{wiz.alert5}" role="alert"
  h5 class="alert-heading"    
    // Tested [100%] 1981 specs
    i class="fas fa-database"
    span class=css = "Tested [#{pct}%]"
    span = "#{cnt} specs"
  .alert-body
    table
      // test  1687 success 4 pending 4 general 162 pseudo 71 macro 8 wrong 45 random  85.2%(1687/1981)
      tr
        td.pr-2 = "test"
        td
          - ok = nil
          - if lights = try.get?
            - grouped = lights.group_by(&.tested)
            - grouped.keys.sort.each do |status|
              - value = status.to_s.downcase
              - count = grouped[status].size
              - focus = (status == status_filter) ? "btn-focus" : ""
              - style = "badge badge-#{status.floor.style} #{focus}"
              a.pjax href="/tested/_/#{value}" title=value
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
          th = "test"
      tbody
        - grouped.each do |src, ary|
          - base = src.sub(/\.cr$/, "")
          - counts = ary.group_by(&.tested).transform_values(&.size)
          - if status_filter == nil || counts[status_filter]?
            tr
              td.pl-1 = human_durations_hash[src]? || "---"
              td.pl-1
                a.pjax href="/tested/#{base}" title=src = src
              td.center  = ary.size
              td.test
                - counts.keys.sort.each do |status|
                  - value = status.to_s.downcase
                  - focus = (status == status_filter) ? "btn-focus" : ""
                  - style = "badge badge-#{status.floor.style} #{focus}"
                  a.pjax href="/tested/#{base}/_/#{value}" title=value
                    span class=style = "#{counts[status]} #{value}"
