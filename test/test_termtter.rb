# -*- coding: utf-8 -*-

require 'rubygems'
require 'test/unit'
require 'kagemusha'
require File.dirname(__FILE__) + '/../lib/termtter'

# TODO: もっとテスト書く！

class TestTermtter < Test::Unit::TestCase
  def setup
    @twitter = Termtter::Twitter.new('test', 'test')

    Termtter::Client.add_hook do |statuses, event|
      @statuses = statuses
      @event = event
    end
  end

  def test_search
    statuses = swap_open('search.json') { @twitter.search('') }
    assert_equal 3, statuses.size
    assert_equal 'test2', statuses[0].user_screen_name
    assert_equal 'texttext 2', statuses[0].text
    assert_equal 'Sat Jan 03 21:49:09 +0900 2009', statuses[0].created_at.to_s
    assert_equal 'test0', statuses[2].user_screen_name
    assert_equal 'texttext 0', statuses[2].text
    assert_equal 'Sat Jan 03 21:49:09 +0900 2009', statuses[2].created_at.to_s
  end

  def test_add_hook
    statuses = nil
    event = nil
    twitter = nil
    Termtter::Client.add_hook do |s, e, t|
      statuses = s
      event = e
      twitter = t
    end

    Termtter::Client.call_hooks([], :foo, @twitter)

    assert_equal [], statuses
    assert_equal :foo, event
    assert_equal @twitter, twitter

    Termtter::Client.clear_hooks()
    statuses = nil
    event = nil
    Termtter::Client.call_hooks([], :foo, @twitter)

    assert_equal nil, statuses
    assert_equal nil, event
  end

  def test_add_command
    command_text = nil
    matche_text = nil
    twitter = nil
    Termtter::Client.add_command /foo\s+(.*)/ do |m, t|
      command_text = m[0]
      matche_text = m[1]
      twitter = t
    end
    
    Termtter::Client.call_commands('foo xxxxxxxxxxxxxx', @twitter)
    assert_equal 'foo xxxxxxxxxxxxxx', command_text
    assert_equal 'xxxxxxxxxxxxxx', matche_text
    assert_equal @twitter, twitter
    
    Termtter::Client.clear_commands()
    assert_raise Termtter::CommandNotFound do
      Termtter::Client.call_commands('foo xxxxxxxxxxxxxx', @twitter)
    end
  end

  def swap_open(name)
    Kagemusha.new(Termtter::Twitter).def(:open) {
      File.open(File.dirname(__FILE__) + "/../test/#{name}")
    }.swap do
      yield
    end
  end
  private :swap_open
end
