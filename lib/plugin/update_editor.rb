require 'tempfile'

module Termtter::Client
  if ENV['EDITOR']
    configatron.plugins.update_editor.set_default('editor', ENV['EDITOR'])
  else
    configatron.plugins.update_editor.set_default('editor', 'vi')
  end

  
  def self.input_editor
    file = Tempfile.new('termtter')
    editor = configatron.plugins.update_editor.editor
    file.close
    system("#{editor} #{file.path}")
    result = file.open.read
    file.close(false)
    result
  end

  add_command /^(update_editor|ue)\s*$/ do |m, t|
    pause
    text = input_editor.gsub("\n", " ")
    unless text.empty?
      t.update_status(text)
      puts "=> #{text}"
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
