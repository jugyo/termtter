require 'rbconfig'
module Termtter::Client
  register_command(
    :name => 'ruby-v',
    :author => 'ujihisa',
    :help => ["ruby-v", "Post the Ruby version you are using"],
    :exec_proc => lambda {|_|
      # see also: http://ujihisa.blogspot.com/2010/03/double-fork-problem-kill-all-processes.html
      ruby = Config::CONFIG["ruby_install_name"] + Config::CONFIG["EXEEXT"]

      result = Termtter::API.twitter.update(`#{ruby} -v`)
      puts "=> " << result.text
  })
end
