module Termtter::Client
  config.prompt = Time.now.strftime('%I:%M%p').downcase << ' > '
end
