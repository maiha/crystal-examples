/ - status_filter : Data::Status?
/ - src           : String # "http/client.cr"

- heuristics = Job::Heuristics.new

- # Models::Example
- try = Try(Array(Models::Example)).try { Models::Example.all("WHERE src = '#{src}' ORDER BY seq") }
- examples = try.get? || Array(Models::Example).new
- examples.each{|s| s.tested = heuristics.skip_test[s.sha1]?.try(&.status?) || s.tested }

- # Models::TestCache
- results = Models::TestCache.all("WHERE src = '#{src}' ORDER BY seq") rescue Array(Models::TestCache).new

- cnt   = examples.size
- alert = "alert-success"
- alert = "alert-secondary" if examples.empty?
- alert = "alert-danger" if examples.any? && examples.map(&.tested.value).max >= Data::Status::ERROR.value
- lang  = config.highlight_lang

== slang "layouts/_breadcrumb"

- if err = try.err?
  span class="badge badge-danger" = err.message || err.class

.m-2

div class="alert #{alert}" role="alert"
  h3 class="alert-heading"
    span class="badge badge-dark" = src
    span = "#{cnt} examples"
  hr
  .stats-box.pretty-box
    - counts = examples.group_by(&.tested).transform_values(&.size)
    = "test: "
    - counts.keys.sort.each do |status|
      - value = status.to_s.downcase
      - focus = (status == status_filter) ? "btn-focus" : nil
      - style = "badge badge-#{status.floor.style} #{focus}"
      - if focus
        a.pjax href="/tested/#{base}" title=value
          span class=style = "#{counts[status]} #{value}"
      - else
        a.pjax href="/tested/#{base}/_/#{value}" title=value
          span class=style = "#{counts[status]} #{value}"
    br
    div style="line-height: 1"
      - examples.each do |s|
        - next if s.seq == 0    # skip "all.cr"
        span class="badge badge-#{s.tested.style}" = s.seq3

  - error_results = results.select(&.exit_code.!= 0)
  - if error_results.any?
    - error_result  = error_results.first
    - error_example = examples.find{|s| s.seq != 0 && s.tested.failure?}
    div class="alert alert-danger" role="alert"
      h5 = "Spec failed (%s)" % error_result.human_duration
      .alert-body
        .crystal-code
          == "<pre><code class=console>%s</code></pre>" % Pretty.ansi2html(error_result.log)
      - if example = error_example
        h5
          span = "at "
        == slang "tested/example"
        - if true # error_result.error_type.undefined_constant?
          #heuristic-require
            - name = error_result.error_value.split("::").first.underscore
            - if src.starts_with?(name)
              - name = ""
              - names = src.sub(/\.cr$/,"").split("/")
              table
                - names.each do |n|
                  - name = name.empty? ? n : "#{name}/#{n}"
                  tr
                    td
                      a class="btn btn-success btn-xs btn-focus" href="#" role="button" onclick="window.CE_heuristic_require(#{example.id}, '#{name}', '#heuristic-require');return false" = %|Add: require "#{name}"|
                    td = %|It may work just by adding 'require'|
      div = "Or fix the example code in '#{src}'"
      a.pjax href="/" class="btn btn-success btn-xs btn-focus" = "Test again"

- examples.each do |example|
  - next if example.seq == 0
  - next if status_filter && example.tested != status_filter
  == slang "tested/example"

javascript:
  $(".crystal-code pre>code").each(function(index, element){
    hljs.highlightBlock(element);
  });
  window.PJAX('a.pjax');
