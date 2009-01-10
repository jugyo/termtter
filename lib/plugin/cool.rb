module Termtter::Client
  add_help 'cool {SCREENNAME}', 'update "@{SCREENNAME} cool."'
  add_macro /^cool ([^\s]*)/, "update @%s cool."
  add_completion do |input|
    case input
    when /^c$/
      ['cool']
    when /^cool ([^\s]*)/
      find_user_candidates $1, "cool %s"
    end
  end
end
