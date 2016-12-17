module Pon::Core
  macro included
    def to_json
      to_h.to_json
    end
  end
end
