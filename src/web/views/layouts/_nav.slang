- navs = Array(Tuple(String, String, String)).new
- navs << {"/db"       , "fas fa-database fa-2x"  , "DB"}
- navs << {"/extracted", "fas fa-cut fa-2x"       , "Extracted"}
- navs << {"/compiled" , "fas fa-running fa-2x"   , "Compiled"}
- navs << {"/tested"   , "fas fa-shield-alt fa-2x", "Tested"}

nav#nav.nav
  - navs.each do |path, icon, title|
    - active = ("/#{controller_name}" =~ /^#{path}/) ? "active" : ""
    a.pjax class="nav-item #{active}" href=path title=title
      i class=icon

javascript:
  $(function(){
    // [pjax:success] adjust active in nav
    $(document).on('pjax:success', function() {
      $('#nav .nav-item').removeClass('active');
      $('#nav .nav-item').each(function(i, e) {
        if (window.location.href.match($(e).attr('href'))) {
          $(e).addClass('active');
        }
      });
    });
  });
