module Termtter::Client
  register_command(
    :name => :lists,
    :exec => lambda {|arg|
      unless arg.empty?
        user_name = normalize_as_user_name(arg)
      else
        user_name = config.user_name
      end
      # TODO: show more information of lists
      puts Termtter::API.twitter.lists(user_name).lists.map{|i| i.full_name}
    }
  )
end
