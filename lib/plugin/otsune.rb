module Termtter::Client
  add_help 'otsune {SCREENNAME}', 'update "@{SCREENNAME} 頭が気の毒です"'
  add_macro /^otsune ([^\s]*)/, "update @%s 頭が気の毒です."
  add_completion do |input|
    case input
    when /^otsune ([^\s]*)/
      find_user_candidates $1, "otsune %s"
    else
      %w(otsune).grep(/^#{Regexp.quote input}/)
    end
  end
end
