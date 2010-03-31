# -*- coding: utf-8 -*-
# あいうえお
module Termtter::Client
  {
    :english => ['hi', 'hey', 'hello', 'How are you?', "How's going?"],
    :spanish => ['hola', '¡Hola!', '¿Cómo estás?'],
    :german => ['Guten Tag!'],
  }.each do |language, greetings|
    greetings.each do |greeting|
      # '¿Cómo estás?' -> 'como_estas'
      command_name = greeting.tr('áó', 'ao').scan(/\w+/).join('_').downcase
      register_command(command_name, :help => ["#{command_name} [(Optinal) USER]", "Post a greeting message in #{language.to_s.capitalize}"]) do |arg|
        result =
          if arg.empty?
            Termtter::API.twitter.update(greeting)
          else
            name = normalize_as_user_name(arg)
            Termtter::API.twitter.update("@#{name} #{greeting}")
          end
        puts "=> " << result.text
      end
    end
  end
end
