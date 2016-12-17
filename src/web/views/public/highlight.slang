style
  / Original theme - https://github.com/chriskempson/tomorrow-theme
  | .hljs {
  |   display: block;
  |   overflow-x: auto;
  |   background: black;
  |   color: #eaeaea;
  |   padding: 0.2em;
  | }
  | 
  | .hljs-emphasis {
  |   font-style: italic;
  | }
  | 
  | .hljs-strong {
  |   font-weight: bold;
  | }

  - config.highlight_custom.each do |key, val|
    - klass = key.split(".").map{|i| ".hljs-#{i}"}.join(" ")
    - style = val.to_s.includes?(":") ? val : "color: #{val}"
    = "%s { %s }" % [klass, style]
