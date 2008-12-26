require 'test/unit'
require File.dirname(__FILE__) + '/../lib/termtter'

class TestTermtter < Test::Unit::TestCase
  def setup
    @termtter = Termtter::Client.new(:user_name => 'test', :password => 'test', :debug => true)
    Termtter::Client.add_hook do |statuses, event|
      @statuses = statuses
      @event = event
    end
  end

  def test_get_timeline
    def @termtter.open(*arg)
      return File.open(File.dirname(__FILE__) + '/../test/friends_timeline.xml')
    end

    statuses = @termtter.get_timeline('')

    assert_equal 3, statuses.size
    assert_equal '102', statuses[0]['user/id']
    assert_equal 'test2', statuses[0]['user/screen_name']
    assert_equal 'Test User 2', statuses[0]['user/name']
    assert_equal 'texttext 2', statuses[0]['text']
    assert_equal 'Thu Dec 25 22:19:57 +0900 2008', statuses[0]['created_at'].to_s
    assert_equal '100', statuses[2]['user/id']
    assert_equal 'test0', statuses[2]['user/screen_name']
    assert_equal 'Test User 0', statuses[2]['user/name']
    assert_equal 'texttext 0', statuses[2]['text']
    assert_equal 'Thu Dec 25 22:10:57 +0900 2008', statuses[2]['created_at'].to_s
  end
  
  def test_get_timeline_with_update_since_id
    def @termtter.open(*arg)
      return File.open(File.dirname(__FILE__) + '/../test/friends_timeline.xml')
    end

    statuses = @termtter.get_timeline('', true)
    assert_equal '10002', @termtter.since_id
  end
  
  def test_search
    def @termtter.open(*arg)
      return File.open(File.dirname(__FILE__) + '/../test/search.atom')
    end

    statuses = @termtter.search('')
    assert_equal 3, statuses.size
    assert_equal 'test2', statuses[0]['user/screen_name']
    assert_equal 'Test User 2', statuses[0]['user/name']
    assert_equal 'texttext 2', statuses[0]['text']
    assert_equal 'Thu Dec 25 22:52:36 +0900 2008', statuses[0]['created_at'].to_s
    assert_equal 'test0', statuses[2]['user/screen_name']
    assert_equal 'Test User 0', statuses[2]['user/name']
    assert_equal 'texttext 0', statuses[2]['text']
    assert_equal 'Thu Dec 25 22:42:36 +0900 2008', statuses[2]['created_at'].to_s
  end
  
  def test_add_hook
    def @termtter.open(*arg)
      return File.open(File.dirname(__FILE__) + '/../test/search.atom')
    end
    call_hook = false
    Termtter::Client.add_hook do |statuses, event|
      call_hook = true
    end
    @termtter.search('')
    
    assert_equal true, call_hook
    
    Termtter::Client.clear_hook()
    call_hook = false
    @termtter.search('')
    
    assert_equal false, call_hook
  end
end

