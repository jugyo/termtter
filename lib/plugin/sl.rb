module Termtter::Client
  public_storage[:current] = ''

  add_macro /^sl\s*$/, 'eval system "sl"'

  add_help 'pwd', 'Show current direcroty'
  add_macro /^pwd\s*$/, 'eval public_storage[:current]'

  add_help 'ls', 'Show list in current directory'
  add_command /^ls\s*$/ do |m, t|
    call_commands "list #{public_storage[:current]}", t
  end

  add_help 'cd USER', 'Change current directory'
  add_command /^(?:cd\s+|\.\/)(.*)/ do |m, t|
    directory = m[1].strip
    directory = '' if /\~/ =~ directory
    public_storage[:current] = directory
    puts "=> #{directory}"
  end
  add_macro /^cd$/, 'eval public_storage[:current] = ""'

  add_completion do |input|
    case input
    when /^(cd\s+|\.\/)(.*)/
      find_user_candidates $2, "#{$1.gsub(/\s+/, ' ')}%s"
    else
      %w[ sl ls cd pwd ./ ].grep(/^#{Regexp.quote input}/)
    end
  end
end
