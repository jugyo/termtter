module Termtter::Client
  register_hook(
    :name => :clock_prompt,
    :point => :prepare_prompt,
    :exec => lambda {|prompt|
      time = Time.now.strftime('%I:%M%p').downcase
      config.prompt = "#{time} #{public_storage[:orig_prompt]}"
    }
  )
end
