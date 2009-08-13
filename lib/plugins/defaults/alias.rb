# -*- coding: utf-8 -*-
#
# Examples for configuration:
# 
#   config.plugins.alias.aliases = {:ls => 'list', :hoge => 'update hoge'}
#
# Examples for command
#
#   > alias ls list
#   > alias me list @jugyo
#   > alias st search termtter
#

config.plugins.alias.set_defaults(:aliases, {})

module Termtter::Client
  @aliases = config.plugins.alias.aliases

  class << self
    def register_alias(alias_name, command)
      @aliases[alias_name.to_sym] = command.to_s
    end

    def remove_alias(alias_name)
      @aliases.delete alias_name.to_sym
    end
  end

  register_command(:alias,
    :help => ['alias NAME COMMAND', 'Add alias for any operations']) do |text|
    unless text.empty?
      alias_name, command = text.split(/\s+/, 2)
      next unless command
      register_alias alias_name, command
      puts "#{alias_name} => #{command}"
    else
      @aliases.keys.sort.each do |k|
        puts "#{k} => #{@aliases[k]}"
      end
    end
  end

  register_command(:remove_alias,
    :help => ['remove_alias NAME', 'Remove alias completely']) do |target|
    remove_alias target
  end

  register_hook :aliases, :point => :pre_command do |text|
    unless text =~ /^\s*$/
      command = text.scan(/\s*([^\s]*)\s*/).flatten.first
      if original = @aliases.has_key?(command.to_sym)
        text = text.sub(command, @aliases[command.to_sym])
      end
    end
    text
  end

  register_hook(:aliases_completion, :point => :completion) do |input|
    if /^\s*([^\s]*)$/ =~ input
      command_str = $1
      @aliases.keys.map{|i|i.to_s}.grep(/^#{Regexp.quote(command_str)}/i)
    end
  end
end
