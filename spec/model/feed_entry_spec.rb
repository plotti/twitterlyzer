require 'spec_helper'
#require './spec/factories'

describe FeedEntry do
  
  before :all do
    system("bundle", "exec", "rake", "sunspot:solr:start")
    begin
      Sunspot.remove_all!
    rescue Errno::ECONNREFUSED
      sleep 2 && retry
    end
  end
    
  after :all do
    system("bundle", "exec", "rake", "sunspot:solr:stop")
  end
  
  it "should collect almost all 3200 Tweets of a person with a lot of tweets" do    
    p = Factory(:person) 
    r = FeedEntry.collect_all_entries p
    FeedEntry.count.should be_close(3200,200)
  end
  
  it "sould not collect tweets that are already collected again" do    
    p = Factory(:person)
    r1 = FeedEntry.collect_all_entries p
    r2 = FeedEntry.collect_all_entries p
    FeedEntry.count.should < 4000
  end
  
  it "should collect the right amount of retweets and persons for a given tweet" do
    f = Factory(:feed_entry)
    FeedEntry.collect_retweet_ids_for_entry(f)
    f.retweet_ids.count.should == f.retweet_count
  end
  
  it "should also work with tweets that have japanese signs" do
    f = Factory(:feed_entry)
    f.guid = 3084096859279360
    FeedEntry.collect_retweet_ids_for_entry(f)
    f.retweet_ids.count.should be_close(94,10)
  end

  
end
