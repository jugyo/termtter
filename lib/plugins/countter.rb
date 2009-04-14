module Termtter::Client
  register_command(
                   :name => :countter,
                   :exec_proc => lambda {|arg|
                     count = {}
                     public_storage[:log].each do |l|
                       source = l.source =~ /(?:<a href=\".+?\">)(.+)(?:<\/a>)/ ? $1 : l.source
                       count[source] = 0 unless count[source]
                       count[source] += 1
                     end

                     format = "%24s %6s"
                     puts format % %w(sources count)
                     puts format % ['-'*24, '-'*6]
                     count.to_a.sort{|a,b|b[1]<=>a[1]}.each do |k,v|
                       puts format % [k, v]
                     end
                   },
                   :completion_proc => lambda {|cmd, arg|
                   },
                   :help => ['countter', 'count sources']
  )
end
