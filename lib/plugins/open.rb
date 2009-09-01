# -*- coding: utf-8 -*-

module Termtter
  module Client
    plug 'uri-open'
    register_command(
      :name => :open, :aliases => [:o],
      :exec_proc => proc {|arg|
        sid, n = arg.split(/ +/)
        if sid.nil?
          call_commands "uri-open"
        else
          target = (n || 1).to_i
          target_uri = nil
          ids = find_status_ids(sid) || []
          ids.each do |id|
            text = Termtter::API.twitter.show(id).text
            URI.extract(text, %w[http https]).each_with_index do |uri, i|
              print "#{i + 1}) #{uri}"
              if i + 1 == target
                target_uri = uri
                print " <-"
              end
              puts ""
            end
          end
          if target_uri
            open_uri target_uri
          end
        end
      },
      :help => ['open,o', 'Open n-th URI in the message']
    )
  end
end

# usage
# > open $dq
# open 1st URI in $dq
# > open $dq 2
# open 2nd URI in $dq
#
# see also
#   http://twitter.com/takiuchi
