class CollectRetweetIdsForEntryJob < Struct.new(:id)
  def perform
    entry = FeedEntry.find(id)
    FeedEntry.collect_retweet_ids_for_entry(entry)
  end  
end

