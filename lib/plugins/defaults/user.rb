module Termtter::Client
  register_command(
    'user show',
    :aliases => [:p, :profile],
    :help => ["user show USERNAME", "Show user's profile."]
  ) do |arg|
    user_name = arg.empty? ? config.user_name : arg
    user = Termtter::API.twitter.user(user_name)
    attrs = %w[ name screen_name url description profile_image_url location protected following
    friends_count followers_count statuses_count favourites_count
    id time_zone created_at utc_offset notifications
    verified geo_enabled lang contributors_enabled
    ]
    label_width = attrs.map(&:size).max
    attrs.each do |attr|
      value = user.__send__(attr.to_sym)
      puts "#{attr.gsub('_', ' ').rjust(label_width)}: #{value}"
    end
  end

  class UserSearchEvent; attr_reader :query; def initialize(query); @query = query end; end

  register_command(
    'user search',
    :help => ["user search QUERY", "search users"]
  ) do |arg|
    search_option = config.user_search.option.empty? ? {} : config.user_search.option
    users = Termtter::API.twitter.search_user(arg, search_option)
    users.each do |user|
      puts "@#{user.screen_name} (#{user.name}): #{user.description}"
    end
  end
end
