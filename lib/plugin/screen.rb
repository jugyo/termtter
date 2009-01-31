# -*- coding: utf-8 -*-

module Termtter

  module Plugin

    module Screen

      def self.set_title(title)

        print "\033k#{title}\033\\"

      end

    end

  end

end



# Add below to your ~/.termtter

#

# require 'plugin/yonda'

# require 'plugin/screen'

# module Termtter::Client

#   add_hook do |statuses, event|

#     case event

#     when :update_friends_timeline, :plugin_yonda_yonda

#       Termtter::Plugin::Screen::set_title("termtter(#{public_storage[:unread_count]})")

#     end

#   end

# end
