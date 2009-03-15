# -*- coding: utf-8 -*-

def create_favorite(id)
  r = Termtter::API.twitter.favorite id
  puts "Favorited status ##{r.id} on user @#{r.user.screen_name} #{r.text}"
end

module Termtter::Client
  register_command(
    :name => :favorite, :aliases => [:fav],
    :exec_proc => lambda {|arg|
      id = 0
      case arg
      when /^\d+/
        id = arg.to_i
      when /^@([A-Za-z0-9_]+)/
        user = $1
        statuses = Termtter::API.twitter.user_timeline(user)
        return if statuses.empty?
        id = statuses[0].id
      when /^\/(.*)$/
        word = $1
        raise "Not implemented yet."
      else
        return
      end

      create_favorite id
    },
    :completion_proc => lambda {|cmd, arg|
      case arg
      when /@(.*)/
        find_user_candidates $1, "#{cmd} @%s"
      when /(\d+)/
        find_status_ids(arg).map{|id| "#{cmd} #{$1}"}
      else
        %w(favorite).grep(/^#{Regexp.quote arg}/)
      end
    },
    :help => ['favorite,fav (ID|@USER|/WORD)', 'Favorite a status']
  )

#   TBD: Implement this when database support comes.
#
#   if public_storage[:log]
#     add_help 'favorite,fav /WORD', 'Favorite a status by searching'
#
#     add_command %r'^(?:favorite|fav)\s+/(.+)$' do |m, t|
#       pat = Regexp.new(m[1])
#       statuses = public_storage[:log].select {|s| pat =~ s.text }
#       if statuses.size == 1
#         status = statuses.first
#         res = t.favorite(status.id)
#         if res.code == '200'
#           puts %Q(Favorited "#{status.user.screen_name}: #{status.text}")
#         else
#           puts "Failed: #{res}"
#         end
#       else
#         puts "#{pat} does not match single status"
#       end
#     end
end
