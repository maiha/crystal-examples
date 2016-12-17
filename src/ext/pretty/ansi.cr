module Pretty::Ansi
  # Don't use constants in `colorize.cr` for the risk of refactoring.
  HTML_COLORS = {
    30 => "black",
    31 => "red",
    32 => "green",
    33 => "yellow",
    34 => "blue",
    35 => "magenta",
    36 => "cyan",
    37 => "lightgray",
  }
  
  def ansi2html(s) : String
    s.to_s.gsub(/\e\[(\d+)(;1)?m(.*?)(\e\[0m)?$/m) do
      code = $1.to_i
      bold = $~[2]? ? "bold" : "normal"
      text = $3
      if color = HTML_COLORS[code]?
        "<span style='color: %s; font-weight: %s;'>%s</span>" % [color, bold, text]
      else
        text
      end
    end
  end

  extend self
end

module Pretty
  extend Ansi
end
