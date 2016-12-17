def remove_ansi_color(s)
  s.to_s.gsub(/\x1B\[[0-9;]*[mK]/, "")
end

def build_random_id(source : Array(String)? = nil, max : Int32 = 6)
  source ||= ('a'..'z').to_a
  (1..max).map{ source.shuffle(Random::Secure) }.join
end

# tab like
def tabish(name : String, id = nil, css = nil)
  id ||= build_random_id(max: 6)
  String.build do |s|
    s << "<div class='#{css}'>" if css
    s << "<div class='nav nav-tabs' role='tablist'>\n"
    s << tab_item id, name, selected: true
    s << "</div>"
    s << "</div>" if css
  end
end

def tab_item(key : String, name : String, selected : Bool = false)
  active = selected ? "active" : nil
  <<-EOF
    <a class="nav-item nav-link #{active}" id="nav-#{key}-tab" data-toggle="tab" href="#nav-#{key}" role="tab" aria-controls="nav-#{key}" aria-selected="#{selected}">#{name}</a>
    EOF
end

def tag_badge(color : Bool | String | Symbol | Nil, msg)
  color = (!!color) ? "success" : "danger" if color.is_a?(Bool?)
  "<span class='badge badge-#{color}'>%s</span>" % [HTML.escape(msg.to_s)]
end

def tag_badges(counts : Hash(Data::Status, Int)) : Array(String)
  array = Array(String).new
  counts.keys.sort.each do |status|
    format = "<span class='badge badge-%s'>%d %s</span>"
    array << format % [status.style, counts[status], status.to_s.downcase]
  end
  return array
end

def tag_pct_bars(counts : Hash(Data::Status, Int), css = nil) : String
  return "" if counts.empty?
  total = counts.values.sum
  counts.map{|status, count|
    pct = (count*100.0/total).trunc.to_i32
    "<span class='stats pct-bar #{css}' style='width: #{pct}%;'></span>"
  }
end
