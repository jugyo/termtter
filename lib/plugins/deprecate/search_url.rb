# -*- coding: utf-8 -*-

module Termtter::Client
  register_command(
   :name => :search_url, :aliases => [],
   :exec_proc => lambda{|arg|
      statuses = public_storage[:log].select {|s| s.text =~ %r!https?://!}
      output(statuses, :search)
   },
   :help => ['search_url', 'Search log for URL']
   )
end
