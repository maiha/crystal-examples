abstract class Cmds::Cmd
  var debug : Bool = false

  {% for m in Log::Severity.constants %}
    def {{m.stringify.downcase.id}}(msg)
      Log.{{m.stringify.downcase.id}} { msg }
    end
  {% end %}
end
