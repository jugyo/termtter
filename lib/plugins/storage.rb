# -*- coding: utf-8 -*-

require 'pp'
require 'time'

require File.dirname(__FILE__) + '/storage/status'

module Termtter::Client
  public_storage[:log] = []

  add_hook do |statuses, event|
    case event
    when :pre_filter
      statuses.each do |s|
        Termtter::Storage::Status.insert(
                                         {
                                           :post_id => s.id,
                                           :created_at => Time.parse(s.created_at).to_i, 
                                           :in_reply_to_status_id => s.in_reply_to_status_id,
                                           :in_reply_to_user_id => s.in_reply_to_user_id,
                                           :post_text => s.text,
                                           :user_id => s.user.id,
                                           :screen_name => s.user.screen_name
                                         }
                                         )
      end
    end
  end


=begin
        register_command(
                         :name => :log,
                         :exec_proc => lambda{|arg|
                           if arg.empty?
                             # log
                             statuses = public_storage[:log]
                             print_max = config.plugins.log.print_max_size
                             print_max = 0 if statuses.size < print_max
                             call_hooks(statuses[-print_max..-1], :search)
                           else
                             # log (user) (max)
                             vars = arg.split(' ')
                             print_max = vars.last =~ /^\d+$/ ? vars.pop.to_i : config.plugins.log.print_max_size
                             id = vars
                             statuses = id.first ? public_storage[:log].select{ |s| id.include? s.user.screen_name} : public_storage[:log]
                             print_max = 0 if statuses.size < print_max
                             call_hooks(statuses[-print_max..-1], :search)
                           end
                         },
                         :completion_proc => lambda {|cmd, arg|
                           find_user_candidates arg, "#{cmd} %s"
                         },
                         :help => [ 'log (USER(S)) (MAX)', 'Show local log of the user(s)']
                         )

        register_command(
                         :name => :search_log, :aliases => [:sl],
                         :exec_proc => lambda{|arg|
                           unless arg.strip.empty?
                             pat = Regexp.new arg
                             statuses = public_storage[:log].select { |s| s.text =~ pat }
                             call_hooks(statuses, :search)
                           end
                         },
                         :help => [ 'search_log WORD', 'Search log for WORD' ]
                         )
=end
end
