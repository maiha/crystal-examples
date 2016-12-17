/ - klass : Pon::Model.class # Models::Example

- wiz = Data::Wizard.new
- css = wiz.css2
- cnt = klass.count
- table_name   = klass.table_name
- records      = klass.all
- grouping_key = grouping_column?(klass)
- grouped      = grouping_key ? records.group_by(&.[grouping_key.to_s]) : {nil => records}

== slang "layouts/_breadcrumb"

.m-2

h2 class="alert-heading"
  span class="badge badge-success" = table_name
  span = "#{cnt} records"

- grouped.each do |grouping_name, array|
  - if grouping_name
    span class="badge badge-dark"
      = grouping_name
      span class="badge badge-pill badge-light" = array.size
    hr.m-0.mb-1

  table#stats-table.ml-2.pretty-table class="table tabls-sm"
    thead.thead-light
      tr
        - klass.new.to_h.keys.each do |key|
          - next if key == "id"
          - next if key == grouping_key
          th = key.to_s
    tbody
      - array.each do |r|
        tr
          - r.to_h.each do |k,v|
            - next if k == "id"
            - next if k == grouping_key
            td.pl-1 = Pretty.truncate(v.to_s, size: 40)

  .m-1
