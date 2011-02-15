require 'spec_helper'
require './spec/factories'

describe FeedEntry do
  
  it "should collect almost all 3200 Tweets of a person with a lot of tweets" do    
    p = Factory(:person) 
    r = FeedEntry.collect_all_entries p
    FeedEntry.count.should be_close(3200,100)
  end
  
  it "sould not collect tweets that are already collected again" do    
    p = Factory(:person)
    r1 = FeedEntry.collect_all_entries p
    r2 = FeedEntry.collect_all_entries p
    FeedEntry.count.should < 4000
  end
  
  it "should collect the right amount of retweets and persons for a given tweet" do
    f = Factory(:feed_entry)
    FeedEntry.collect_retweet_ids(f)
    f.retweet_ids.count.should == 6
  end
  
  # Me including my 6 retweets
  it "should collect the right amount of persons for a given retweet" do
    f = Factory(:feed_entry)
    FeedEntry.collect_retweet_ids(f)
    f.person.project.first.persons.count.should == 7
  end
  
end
