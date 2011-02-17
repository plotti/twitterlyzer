class CollectFeedEntryAndRetweetsJob < Struct.new(:project_id, :twitter_id)
  def perform    
    entry = FeedEntry.collect_entry_and_person(twitter_id,project_id)
    FeedEntry.collect_retweet_ids_for_entry(entry)
  end  
end