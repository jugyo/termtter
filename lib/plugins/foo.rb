# coding: utf-8

module Termtter::Client

  register_command(:foo, :help => ['foo', 'Say foo']) do |args|
    Termtter::API.twitter.update('foo')
    puts "=> foo"
  end

  register_hook(:foo, :point => :filter_for_output) do |statuses, event|
    statuses.each do |s|
      s.text.sub!(/\A.+\z/, 'foo')
    end
  end
end

