# -*- coding: utf-8 -*-

module Termtter::Client
  public_storage[:curry] = ''

  register_command(
    :name => :curry,
    :alias => :<,
    :exec => lambda {|arg|
      unless arg.empty?
        public_storage[:curry] += arg + ' '
      end
    },
    :completion => lambda {|cmd, arg|
      commands.map{|name, command| command.complement(arg)}.
        flatten.
        compact.
        map{|i| "#{cmd} #{i}"}
    }
  )

  register_command(
    :name => :uncurry,
    :alias => :>,
    :exec=> lambda {|arg|
      public_storage[:curry] = ''
    }
  )

  register_hook(
    :name => :apply_curry,
    :point => :prepare_command,
    :exec => lambda {|text|
      /^(curry|<|uncurry|>)/ =~ text ? text : public_storage[:curry] + text
    }
  )

  register_hook(
    :name => :curry_prompt,
    :point => :prepare_prompt,
    :exec => lambda {|prompt| public_storage[:curry] + prompt }
  )
end
