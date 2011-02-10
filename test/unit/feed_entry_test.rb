require File.dirname(__FILE__) + '/../test_helper'

class FeedEntryTest < ActiveSupport::TestCase

  FEED = "http://www.spiegel.de/schlagzeilen/tops/index.rss"
  
  def setup
    @feed_entry = feed_entries(:one)
    @person = people(:one)    
  end
  
  def teardown
    @feed_entry = nil
    @person = nil
  end
  
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  #Tests if the feed parsing works
  def test_should_parse_feed
    assert FeedEntry.parse_feed(FEED)  
  end
  
  #TODO
  def test_should_update_rss
    assert true
  end
  
  def test_should_get_all_rss    
    assert FeedEntry.get_all_rss(@person)
  end
  
  def test_should_get_remaining_api_hits    
    assert FeedEntry.get_remaining_api_hits
  end
  
  def shoud_not_add_same_entries
    entries_before = FeedEntry.all.count
    FeedEntry.add_entries(@feed_entry,@person)
    entries_after = FeedEntry.all.count
    assert_equal entries_before entries_after
  end
  
  def shoud_add_different_entries
    entries_before = FeedEntry.all.count
    new_entry = FeedEtry.new(:guid => "something_else")
    FeedEntry.add(new_entry,@person)
    entries_after = FeedEntry.all.count
    !assert_equal entries_before entries_after
  end

end
