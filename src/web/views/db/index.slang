- wiz    = Data::Wizard.new
- tables = wiz.tables
- css    = wiz.css2

== slang "layouts/_breadcrumb"

.m-2
div
  table class="table table-sm table-compact"
    thead.thead-light
      tr
        th
        th = "table"
        th = "count"
        th = "schema"
    tbody
      - tables.each do |table|
        - name = table.name
        - css  = (table.exists ? "passed" : "failed")
        tr class=css
          td
            i class="fas fa-database"
          td
            a.pjax href="/db/#{name}" title="#{name}" = name
          td.center
            - if table.exists
              span class="badge badge-success" = table.count
            - else
              span class="badge badge-danger" = "N/A"
          td
            = table.schema
