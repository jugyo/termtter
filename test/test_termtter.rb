require 'rubygems'
require 'configatron'
require 'test/unit'
require 'kagemusha'
require File.dirname(__FILE__) + '/../lib/termtter'

class TestTermtter < Test::Unit::TestCase
  def setup
    @twitter = Termtter::Twitter.new('test', 'test')

    Termtter::Client.add_hook do |statuses, event|
      @statuses = statuses
      @event = event
    end
  end

  def test_get_timeline
    statuses = swap_open('friends_timeline.json') { @twitter.get_timeline('') }

    assert_equal 3, statuses.size

    assert_equal 102, statuses[0].user_id
    assert_equal 'test2', statuses[0].user_screen_name
    assert_equal 'Test User 2', statuses[0].user_name
    assert_equal 'texttext 2', statuses[0].text
    assert_equal 'http://twitter.com/test2', statuses[0].user_url
    assert_equal 'http://s3.amazonaws.com/twitter_production/profile_images/000/102.png', statuses[0].user_profile_image_url
    assert_equal 'Sat Jan 03 21:13:45 +0900 2009', statuses[0].created_at.to_s

    assert_equal 100, statuses[2].user_id
    assert_equal 'test0', statuses[2].user_screen_name
    assert_equal 'Test User 0', statuses[2].user_name
    assert_equal 'texttext 0', statuses[2].text
    assert_equal 'http://twitter.com/test0', statuses[2].user_url
    assert_equal 'http://s3.amazonaws.com/twitter_production/profile_images/000/100.png', statuses[2].user_profile_image_url
    assert_equal 'Sat Jan 03 21:13:45 +0900 2009', statuses[2].created_at.to_s
  end

  def test_get_timeline_with_update_since_id
    statuses = swap_open('friends_timeline.json') { @twitter.get_timeline('', true) }
    assert_equal 10002, @twitter.since_id
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
