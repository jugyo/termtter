module Termtter::Client
  register_hook(:easy_post, :point => :command_not_found) do |text|
    execute("update #{text}")
  end
end
