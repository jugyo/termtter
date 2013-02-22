# -*- coding: utf-8 -*-
module Termtter::Client
  register_command(
    :name => :list, :aliases => [:l],
    :exec_proc => lambda {|arg|
      _, options, user = */((?:\-[a-z][= ]\S+\s*)+)?(?:@?(\w+))?/.match(arg)
      params = {:include_entities => 1}
      options.scan(/(\-[a-z])[= ](\S+)/).each do |k,v|
        v = v.sub(/^['"]/,'').sub(/['"]$/,'')
        case k
        when '-n' #count
          params['count'] = v.to_i if v.to_i > 0
        when '-p' #page
          params['page'] = v.to_i if v.to_i > 0
        end
      end if options

      unless user
        event = :list_friends_timeline
        statuses = Termtter::API.twitter.friends_timeline(params)
      else
        event = :list_user_timeline
        statuses = Termtter::API.twitter.user_timeline({:screen_name => user}.merge(params))
      end
      output(statuses, event)
    },
    :help => ["list,l [USERNAME]", "List the posts"]
  )
end
