require 'tempfile'

module Termtter::Client
  if ENV['EDITOR']
    configatron.plugins.update_editor.set_default('editor', ENV['EDITOR'])
  else
    configatron.plugins.update_editor.set_default('editor', 'vi')
  end
  configatron.plugins.update_editor.set_default('add_completion', false)

  
  def self.input_editor
    file = Tempfile.new('termtter')
    editor = configatron.plugins.update_editor.editor
    if configatron.plugins.update_editor.add_completion
      file.puts "\n"*100 + "__END__\n" + public_storage[:users].to_a.join(' ')
    end
    file.close
    system("#{editor} #{file.path}")
    result = file.open.read
    file.close(false)
    result
  end

  add_command /^(update_editor|ue)\s*$/ do |m, t|
    pause
    text = input_editor
    unless text.empty?
      text = ERB.new(text).result(binding)
      text.split("\n").each do |post|
        break if post =~ /^__END__$/
        unless post.empty?
          t.update_status(post)
          puts "=> #{post}"
        end
      end
    end
    resume
  end

  add_help 'update_editor,ue', 'Update status from editor.'

  add_completion do |input|
    %w[ update_editor ].grep(/^#{Regexp.quote input}/)
  end
end

# update_editor.rb
#   update status from editor.
# example:
#   > update_editor
#   (type your status, save, close the editor)
#   => (your status)
