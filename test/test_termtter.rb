require 'rubygems'
require 'configatron'
require 'test/unit'
require 'kagemusha'
require File.dirname(__FILE__) + '/../lib/termtter'

class TestTermtter < Test::Unit::TestCase
  def setup
    configatron.user_name = 'test'
    configatron.password = 'test'
    @termtter = Termtter::Client.new

    Termtter::Client.add_hook do |statuses, event|
      @statuses = statuses
      @event = event
    end
  end

  def test_get_timeline
    statuses = swap_open('friends_timeline.xml') { @termtter.get_timeline('') }

    assert_equal 3, statuses.size
    assert_equal '102', statuses[0].user_id
    assert_equal 'test2', statuses[0].user_screen_name
    assert_equal 'Test User 2', statuses[0].user_name
    assert_equal 'texttext 2', statuses[0].text
    assert_equal 'Thu Dec 25 22:19:57 +0900 2008', statuses[0].created_at.to_s
    assert_equal '100', statuses[2].user_id
    assert_equal 'test0', statuses[2].user_screen_name
    assert_equal 'Test User 0', statuses[2].user_name
    assert_equal 'texttext 0', statuses[2].text
    assert_equal 'Thu Dec 25 22:10:57 +0900 2008', statuses[2].created_at.to_s
  end

  def test_get_timeline_with_update_since_id
    statuses = swap_open('friends_timeline.xml') { @termtter.get_timeline('', true) }
    assert_equal '10002', @termtter.since_id
  end

  def test_search
    statuses = swap_open('search.atom') { @termtter.search('') }
    assert_equal 3, statuses.size
    assert_equal 'test2', statuses[0].user_screen_name
    assert_equal 'Test User 2', statuses[0].user_name
    assert_equal 'texttext 2', statuses[0].text
    assert_equal 'Thu Dec 25 22:52:36 +0900 2008', statuses[0].created_at.to_s
    assert_equal 'test0', statuses[2].user_screen_name
    assert_equal 'Test User 0', statuses[2].user_name
    assert_equal 'texttext 0', statuses[2].text
    assert_equal 'Thu Dec 25 22:42:36 +0900 2008', statuses[2].created_at.to_s
  end

  def test_add_hook
    call_hook = false
    Termtter::Client.add_hook do |statuses, event|
      call_hook = true
    end
    swap_open('search.atom'){ @termtter.search('') }

    assert_equal true, call_hook

    Termtter::Client.clear_hooks()
    call_hook = false
    @termtter.search('')

    assert_equal false, call_hook
  end
  
  def test_add_command
    command_text = nil
    matche_text = nil
    Termtter::Client.add_command /foo\s+(.*)/ do |matche|
      command_text = matche[0]
      matche_text = matche[1]
    end
    
    @termtter.call_commands('foo xxxxxxxxxxxxxx')
    assert_equal 'foo xxxxxxxxxxxxxx', command_text
    assert_equal 'xxxxxxxxxxxxxx', matche_text
    
    Termtter::Client.clear_commands()
    assert_raise Termtter::CommandNotFound do
      @termtter.call_commands('foo xxxxxxxxxxxxxx')
    end
  end

  def swap_open(name)
    Kagemusha.new(Termtter::Client).def(:open) {
      File.open(File.dirname(__FILE__) + "/../test/#{name}")
    }.swap do
      yield
    end
  end
  private :swap_open
end
