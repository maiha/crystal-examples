- breadcrumbs = env.breadcrumbs

- if breadcrumbs.any?
  nav
    ol.breadcrumb.mb-1.p-0.pl-2.pr-1
      - breadcrumbs.each do |b|
        li.breadcrumb-item
          a.pjax href="#{b.path}" = b.name
