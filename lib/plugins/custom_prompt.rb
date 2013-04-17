module Termtter::Client
  register_hook(
    :name => :custom_prompt,
    :point => :prepare_prompt,
    :exec => lambda {|prompt|
      time = Time.now.strftime('%H:%M:%S')
      config.prompt = "(#{time}) #{config.user_name}: "
    }
  )
end
