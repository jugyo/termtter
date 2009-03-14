# -*- coding: utf-8 -*-

require 'tempfile'

module Termtter::Client
  if ENV['EDITOR']
    config.plugins.update_editor.set_default('editor', ENV['EDITOR'])
  else
    config.plugins.update_editor.set_default('editor', 'vi')
  end
  config.plugins.update_editor.set_default('add_completion', false)

  
  def self.input_editor
    file = Tempfile.new('termtter')
    editor = config.plugins.update_editor.editor
    if config.plugins.update_editor.add_completion
      file.puts "\n"*100 + "__END__\n" + public_storage[:users].to_a.join(' ')
    end
    file.close
    system("#{editor} #{file.path}")
    result = file.open.read
    file.close(false)
    result
  end

  register_command(
                   :name => :update_editor, :aliases => [:ue],
                   :exec_proc => lambda{|arg|
                     pause
                     text = input_editor
                     unless text.empty?
                       text = ERB.new(text).result(binding)
                       text.split("\n").each do |post|
                         break if post =~ /^__END__$/
                         unless post.empty?
                           Termtter::API.twitter.update_status(post)
                           puts "=> #{post}"
                         end
                       end
                     end
                     resume
                   },
                   :help => ["update_editor,ue", "Update status from editor."]
                   )
end

# update_editor.rb
#   update status from editor.
# example:
#   > update_editor
#   (type your status, save, close the editor)
#   => (your status)
