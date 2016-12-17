- icon   = config.web_step4_icon.gsub(/fa-\dx/, "")
- valid  = wiz.valid4
- pct    = wiz.pct4
- cnt    = wiz.cnt4

- if src_dir = config.crystal_src_dir?
  .job-operations
    .card.card-sm.border-secondary
      .card-header
        button#compile-btn type="button" class="btn btn-primary btn-sm btn-focus" onclick="window.wsjob_compile.onclick();return false"
          = "Compile"
        span#compile-info
      .card-body
        == "Compile extracted examples again. (several minutes)"
  .m-2

div#compile class="alert #{wiz.alert4}" role="alert"
  h5 class="alert-heading"
    span.job-data.float-right style="font-size:80%"
    = "Compiled : "
    span.job-pct = pct
    = "%"

  .stats-graph
    span.stats.job-pct-bar style="width: #{pct}%;"
    i class=icon style="margin-top:-10px;"

  .stats-box.pretty-box
    span = "#{cnt} files"
    == tag_badges(wiz.compact_compiled_counts).join("\n")
    div.float-right
      a.pjax href="/compiled" class="btn btn-success btn-xs btn-focus" = "See detail"

javascript:
  $(function(){
    var vars = {
      topic: 'compile',
      start: 'Compile',
      stop:  'Stop',

      pct:     '#compile .job-pct',
      data:    '#compile .job-data',
      bar:     '#compile .job-pct-bar',
      btn:     '#compile-btn',
      info:    '#compile-info',

      spinner: $('<span>').addClass("spinner-border spinner-border-sm"),
    };

    var job = {
      // ws event
      onmessage: function(d) {
        if (d.topic == vars.topic) {
          if (d.pct == -1) {
            job.changed(false);
            $(vars.data).text(d.data);
          } else {
            $(vars.pct ).text(d.pct);
            $(vars.data).text(d.data);
            $(vars.bar ).width(d.pct + '%');
            if (d.pct == 100) {
              job.changed(false);
              // refresh page
              $('#logo a.pjax').click();
            } else {
              // update each time for the case of running by other users
              job.changed(true);
            }
          }
        }
      },

      log: function(msg) {
        console.log('[' + vars.topic + ']', msg);
      },

      lock_btn: function(msg) {
        $(vars.btn).prop("disabled", true);
        if (msg) { $(vars.info).text(msg) }
      },

      unlock_btn: function(msg) {
        $(vars.btn).prop("disabled", false);
        if (msg) { $(vars.info).text(msg) }
      },

      start: function() {
        job.log("start")

        job.lock_btn(""); // prevent double clicked
        $.ajax({
          url: '/job/' + vars.topic + '/start',
          type: "POST"
        })
        .done((json, textStatus, jqXHR) => {
          job.log('start.done');
          job.changed(json.start);
          if (json.reason) { $(vars.info).text(json.reason) }
        })
        .fail((jqXHR, textStatus, errorThrown) => {
          job.log('start.fail', jqXHR.status);
          $(vars.info).text(textStatus);
          job.changed(false);
        });
      },

      stop: function() {
        job.log('stop');

        job.lock_btn(""); // prevent double clicked
        $.ajax({
          url: '/job/' + vars.topic + '/stop',
          type: "POST"
        })
        .done((json, textStatus, jqXHR) => {
          job.log('stop.done', json);
          if (json.stop == true) {
            // "unlock" will be automatically fired by "onmessage"
          } else {
            // Fire "unlock" because no further messages will come.
            job.unlock_btn();
          }
          if (json.reason) { $(vars.info).text(json.reason) }
        })
        .fail((jqXHR, textStatus, errorThrown) => {
          job.log('stop.fail', jqXHR.status);
          job.unlock_btn(textStatus);
        });
      },

      changed: function(running) {
        job.log('changed')
        var btn = $(vars.btn);

        btn.prop("disabled", false);
        btn.empty().attr('data-running', running.toString());
        if (running) {
          btn.removeClass("btn-primary").addClass("btn-danger");
          btn.append(vars.spinner);
          btn.append($('<span>').text(' ' + vars.stop));
        } else {
          btn.removeClass("btn-danger").addClass("btn-primary");
          btn.append($('<span>').text(' ' + vars.start));
        }
      },

      onclick: function() {
        job.log('onclick')
        var running = !!($(vars.btn).attr('data-running') == 'true');
        if (running) {
          job.stop();
        } else {
          job.start();
        }
      }
    };

    window.wsjob_compile = job;
  });
