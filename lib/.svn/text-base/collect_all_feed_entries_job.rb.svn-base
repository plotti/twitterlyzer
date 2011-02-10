class CollectAllFeedEntriesJob < Struct.new(:id)
  def perform
    person = Person.find(id)
    FeedEntry.collect_all_entries(person)    
  end
end