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

end
