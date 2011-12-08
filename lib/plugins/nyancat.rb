# coding: utf-8
module Termtter::Client
  register_command(:nyancat, :help => ['nyancat', '♡']) do |msg|
    unless system('nyancat')
      warn <<-EOS.gsub(/ {8}/, '')
        Oh, You don't have nyancat yet. Please install it:

            $ gem install nyancat

      EOS
    end
  end
end

