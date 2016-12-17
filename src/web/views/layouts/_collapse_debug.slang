button#collapseDebugBtn type="button" class="btn btn-secondary btn-xs float-right" data-toggle="collapse" data-target="#collapseDebug" aria-expanded="false" aria-controls="collapseDebug" = "DEBUG"

javascript:
  $(function(){
    var cookie_key = "crystal-examples.collapseDebug";
    var expanded = (($.cookie(cookie_key) || false).toString() == 'true');
    if (expanded) {
      $("#collapseDebug").collapse('show');
    }
    $("#collapseDebugBtn").click(function () {
      var value = ($(this).attr("aria-expanded") == 'false');
      // console.log("COOKIE: set " + cookie_key + " => " + value.toString());
      $.cookie(cookie_key, value.toString(), {path:'/', expires:365});
    });
  });
