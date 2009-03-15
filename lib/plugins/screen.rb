# -*- coding: utf-8 -*-

module Termtter
  module Plugin
    module Screen
      def self.set_title(title)
        print "\033k#{title}\033\\\n"
      end
    end
  end
end

# Add below to your ~/.termtter
#
# require 'plugins/yonda'
# require 'plugins/screen'
# module Termtter::Client
#   register_hook(:name => :screen,
#                 :points => [:post_exec__update_timeline, :plugin_yonda_yonda, :post_exec_yonda],
#                 :exec_proc => lambda { |cmd, arg, result|
#                   Termtter::Plugin::Screen::set_title("termtter(#{public_storage[:unread_count]})")
#                 }
#   )
# end
