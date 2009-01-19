require 'rubygems'
require 'tumblr'

module Termtter::Client
  add_help 'reblog ID', 'Tumblr Reblog a status'

  add_command %r'^reblog\s+(\d+)(.*)$' do |m, t|
    id = m[1]
    comment = m[2].strip
    statuses = public_storage[:log].select { |s| s.id == id }
    unless statuses.empty?
      status = statuses.first
    else
      status = t.show(id).first
    end

    Tumblr::API.write(configatron.plugins.reblog.email, configatron.plugins.reblog.password) do
      quote("#{status.text}", "<a href=\"http://twitter.com/#{status.user_screen_name}/status/#{status.id}\">Twitter / #{status.user_name}</a>")
    end
  end

  add_completion do |input|
    case input
    when /^(reblog)\s+(\d*)$/
      find_status_id_candidates $2, "#{$1} %s"
    else
      %w(reblog).grep(/^#{Regexp.quote input}/)
    end
  end
end

# reblog.rb
# tumblr reblog it!
#
# configatron.plugins.reblog.email = 'your-email-on-tumblr'
# configatron.plugins.reblog.password = 'your-password-on-tumblr'
#
#   reblog 1114860346
