- icon   = config.web_step1_icon.gsub(/fa-\dx/, "")
- css    = wiz.css1
- sample = wiz.sample1
- valid  = wiz.valid1

div class="alert #{wiz.alert1}" role="alert"
  h5 class="alert-heading" = "Config : %s" % config.source?.inspect
  hr
  
  span class="badge badge-dark" = "[crystal]"
  ul class="list-group list-group-flush setting-list-group"
    li class="list-group-item"
      span class="badge badge-light" = "src_dir = "
      span = config.crystal_src_dir?.inspect
      - if valid
        span class="badge badge-success" = "OK"
      - else
        span class="badge badge-danger" = "not found: #{sample.inspect}"
  
  span class="badge badge-dark" = "[db]"
  ul class="list-group list-group-flush setting-list-group"
    li class="list-group-item"
      span class="badge badge-light" = "sqlite = "
      span = config.db_sqlite?.inspect
      - if config.db_sqlite?
        span class="badge badge-success" = "OK"
      - else
        span class="badge badge-danger" = "NG"
