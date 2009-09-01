# -*- coding: utf-8 -*-

module Termtter::Client
  @outputs = { }
  class << self
    def register_output(as, &block)
      @outputs[as] = block
    end

    def delete_output(name)
      @outputs.delete(name)
    end

    def puts message
      @outputs.each_value do |block|
        block.call(message)
      end
    end
  end
end

module Termtter::Client
  register_command(
    :name => :outputs,
    :exec_proc => lambda {|arg|
      puts @outputs.keys.inspect
    },
    :help => ['outputs', 'Show outputs']
    )

  register_output(:stdout) do |msg|
    STDOUT.puts(msg)
  end
end
