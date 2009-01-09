module Termtter::Client
  public_storage[:current] = ''

  add_macro /^sl\s*$/, 'eval system "sl"'

  add_macro /^pwd\s*$/, 'eval public_storage[:current]'

  add_help 'ls', 'Show current directory'
  add_command /^ls\s*$/ do |m, t|
    call_commands "list #{public_storage[:current]}", t
  end

  add_help 'cd USER', 'Change current directory'
  add_command /^cd\s+(.*)/ do |m, t|
    public_storage[:current] = m[1].strip
  end

  add_completion do |input|
    case input
    when /^(cd)\s+(.*)/
      find_user_candidates $2, "#{$1} %s"
    else
      %w[ sl ls cd pwd ].grep(/^#{Regexp.quote input}/)
    end
  end
end
