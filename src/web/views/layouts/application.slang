doctype html
html
  head
    meta charset="UTF-8" /
    title= config.web_header_title
    meta http-equiv="X-UA-Compatible" content="IE=edge"
    meta name="viewport" content="width=device-width, initial-scale=1"

    / jquery3
    script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"
    script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js"
    script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-cookie/1.4.1/jquery.cookie.js"
    script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.pjax/2.0.1/jquery.pjax.min.js"

    / bootstrap4
    link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css" integrity="sha384-GJzZqFGwb1QTTN6wy59ffF1BuGJpLSa9DkKMp0DgiMDm4iYMj70gZWKYbI706tWS" crossorigin="anonymous"
    script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js" integrity="sha384-wHAiFfRlMFy6i5SRaxvfOCifBUQy1xHdJ/yoi7FRNXMRBu5WHdZYu1hA6ZOblgut" crossorigin="anonymous"
    script src="https://stackpath.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js" integrity="sha384-B0UglyR+jN6CkvvICOB2joaf5I4l3gm9GU6Hc1og6Ls7i6U/mkkaduKaBhlAXv9k" crossorigin="anonymous"

    / Font Awesome
    link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.5.0/css/all.css" integrity="sha384-B4dIYHKNBt8Bc12p+WXckhzcICo0wtJAoU8YZTY5qE0Id1GSseTk6S+L3BlXeVIU" crossorigin="anonymous"

    / progress bar
    link rel="stylesheet" href="//unpkg.com/nprogress@0.2.0/nprogress.css"
    script src="//unpkg.com/nprogress@0.2.0/nprogress.js"

    / highlight.js
    - version = config.highlight_version
    - style   = config.highlight_style?.to_s
    - if style.size > 0
      link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/#{version}/styles/#{style}.min.css"
    == slang "public/highlight"
    script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/#{version}/highlight.min.js"
    script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.14.2/languages/crystal.min.js"

    / application
    script src="/public/main.js"
    link rel="stylesheet" href="/public/main.css"

  body
    div.masthead
      .docker_info
        - css = Data::SystemInfo.docker? ? "success" : "danger"
        span class="badge badge-#{css}" = "docker"
      .crystal_info = config.try_crystal_version.get? || "error"
      #logo.logo.float-left
        a.pjax href="/" style="color: #{config.web_logo_color}"
          i class=config.web_logo_icon
      .container
        == slang "layouts/_nav"
    /== slang "parts/notices"
    == slang "layouts/_modal"
    #toasts
    #ajaxAlert.alert.alert-danger style="display:none"

    div.container style="max-width: 95%"
      #content == content

    hr
    #footer
      .float-right
        a href="https://github.com/maiha/crystal-examples" = Shard.git_description

javascript:
  $(function(){
    // Attach pjax handler
    window.PJAX('a.pjax');

    hljs.initHighlightingOnLoad();
  });
