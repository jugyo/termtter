module Termtter::Client
  register_command(
    :name => 'ruby-v',
    :author => 'ujihisa',
    :help => ["ruby-v", "Post the Ruby version you are using"],
    :exec_proc => lambda {|_|
      result = Termtter::API.twitter.update("#{RUBY_DESCRIPTION} #termtterrubyversion")
      puts "=> " << result.text
  })
end
