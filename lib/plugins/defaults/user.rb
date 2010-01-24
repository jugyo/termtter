module Termtter::Client
  register_command(
    %s{user show},
    :aliases => [:p, :profile],
    :help => ["user show USERNAME", "Show user's profile."]
  ) do |arg|
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
  end

  class UserSearchEvent; attr_reader :query; def initialize(query); @query = query end; end

  register_command(
    'user search',
    :help => ["user search QUERY", "search users"]
  ) do |arg|
    search_option = config.user_search.option.empty? ? {} : config.user_search.option
    statuses = Termtter::API.twitter.search_user(arg, search_option)
    results = []
    statuses.select{|s| s.status != nil }.map do |s|
      result = {
        :id => s.status.id,
        :text => s.status.text,
        :in_reply_to_status_id => s.in_reply_to_status_id,
        :created_at => s.created_at,
        :user => {:id => s.id, :name => s.name, :screen_name => s.screen_name}
      }
      results << Rubytter.structize(result)
    end
    output(results, UserSearchEvent.new(arg))
  end

  register_hook(:highlight_for_user_search, :point => :pre_coloring) do |text, event|
    case event
    when UserSearchEvent
      query = event.query.split(/\s/).map {|q|Regexp.quote(q)}.join("|")
      text.gsub(/(#{query})(.*:)/i, '<on_magenta><white>\1</white></on_magenta>\2')
    else
      text
    end
  end
end
