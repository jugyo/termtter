module Termtter::Client
  register_command(
    :name => :user, :aliases => [:profile, :p],
    :exec_proc => lambda {|arg|
      user_name = arg.empty? ? config.user_name : arg
      user = Termtter::API.twitter.user(user_name)
      attrs = %w[ name screen_name url description profile_image_url location protected following
        friends_count followers_count statuses_count favourites_count
        id time_zone created_at utc_offset notifications
      ]
      label_width = attrs.map(&:size).max
      attrs.each do |attr|
        value = user.__send__(attr.to_sym)
        puts "#{attr.gsub('_', ' ').rjust(label_width)}: #{value}"
      end
    },
    :help => ["user [USERNAME]", "Show user's profile."]
  )
end
