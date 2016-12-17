- icon   = config.web_step2_icon.gsub(/fa-\dx/, "")
- css   = wiz.css2
- valid = wiz.valid2

- unless valid
  div class="alert alert-warning" role="alert"
    h5.alert-heading = "Database Not Ready"
    span = "Run the the following 'Reset Database' for the first time."

div class="alert #{wiz.alert2}" role="alert"
  h5 class="alert-heading" = "Database : %s" % config.db_sqlite?.inspect
  hr

  span class="badge badge-dark" = "tables"
  table class="table table-sm table-compact"
    tbody
      - wiz.tables.each do |table|
        - css = (table.exists ? "passed" : "failed")
        tr class=css
          td
            i class="fas fa-database"
          td
            = table.name
          td.center
            - if table.exists
              span class="badge badge-success" = table.count
            - else
              span class="badge badge-danger" = "not found"
          td
            - if table.exists
              a.pjax pjax_push="false" method="POST" class="btn btn-danger btn-focus btn-xs" href="/job/db/reset/#{table.name}" role="button" = "Reset"
            - else
              a.pjax pjax_push="false" method="POST" class="btn btn-success btn-focus btn-xs" href="/job/db/reset/#{table.name}" role="button" = "Create"
          td
            - case table.name
            - when "heuristics"
              a.heuristic-dump.ml-1 pjax_push="false" class="btn btn-primary btn-xs btn-focus" href="#" role="button" onclick="window.CE_ajax('/heuristic/dump', '.heuristic-dump');return false" = "Dump to file"
              a.heuristic-load.ml-1 pjax_push="false" class="btn btn-warning btn-xs btn-focus" href="#" role="button" onclick="window.CE_ajax('/heuristic/load', '.heuristic-load');return false" = "Load from file"
              a.heuristic-diff.ml-1 class="btn btn-success btn-xs btn-focus" href="/heuristic/diff" data-toggle="modal" data-target="#modal" = "Check my heuristics"
  hr

  .card.border-danger
    .card-header
      a.pjax pjax_push="false" method="POST" class="btn btn-danger btn-sm btn-focus" href="/job/db/reset" role="button" = "Reset Database"
    .card-body
      | The database file will be deleted and re-created.
      | (a few seconds)
