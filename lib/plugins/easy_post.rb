module Termtter::Client
  register_hook(:easy_post, :point => :command_not_found) do |text|
    if config.confirm && text.length > 15
      execute("update #{text}")
    else
      raise Termtter::CommandNotFound, text
    end
  end
end
