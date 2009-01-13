module Termtter::Client
  add_help 'otsune {SCREENNAME}', 'update "@{SCREENNAME} 頭蓋骨の中身がお気の毒です"'
  add_help 'otsnue {SCREENNAME}', 'update "@{SCREENNAME} 頭が気の毒です"'

  add_macro /^otsune ([^\s]*)/, "update @%s 頭蓋骨の中身がお気の毒です."
  add_macro /^otsnue ([^\s]*)/, "update @%s 頭が気の毒です."

  add_completion do |input|
    case input
    when /^(otsune|otsnue) ([^\s]*)/
      find_user_candidates $2, "#{$1} %s"
    else
      %w[otsune otsnue].grep(/^#{Regexp.quote input}/)
    end
  end
end
