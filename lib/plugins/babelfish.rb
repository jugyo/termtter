# gem install sishen-rtranslate --source http://gems.github.com --no-ri --no-rdoc
# >= 1.2
require 'rtranslate'

config.plugins.babelfish.set_default(:default_lang, 'en,hu')

Termtter::Client.register_hook(
  :name => :babelfish,
  :point => :filter_for_output,
  :help => ['language settings', 'call babel_lang proc!'],
  :exec_proc => lambda {|statuses, event|
    statuses.each do |s|
      lang = Translate.d( s.text ) # autodetecting language
      unless config.plugins.babelfish.default_lang.split(',').include?( lang ) # is it understandable? 
        pre_check = Translate.t( s.text, '', config.plugins.babelfish.default_lang.split(',').first ) # translate
        s[:text]= "#{pre_check}~#{lang}" unless pre_check =~ /^Error/ # modify display
      end
    end
  }
)

Termtter::Client.register_command(
  :name => :babel_lang,
  :exec_proc => lambda { |arg|
  unless arg.empty?
    puts "setting default language to '#{arg}'."
    config.plugins.babelfish.default_lang= arg
  else
    puts "Babelfish language settings: #{config.plugins.babelfish.default_lang}"
    puts 'You can specify more languages with colon: like "en,hu" wich means always translate to english but acceptable original tweets in english and hungarian too. '
  end

  }
)
