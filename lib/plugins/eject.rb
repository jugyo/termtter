# -*- coding: utf-8 -*-

if /linux/ =~ PLATFORM
  module Termtter::Client
    help = ['eject [-t]', 'eject or close']
    register_command(:eject, :help => help) do |flag|
      if flag.empty?
        system 'eject'
      else
        system 'eject -t'
      end
    end
  end
end

