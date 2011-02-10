class CollectRetweetIdsJob < Struct.new(:id)
  def perform
    entry = FeedEntry.find(id)    
    FeedEntry.collect_retweet_ids(entry)
  end
end