class SearchResult < ActiveRecord::Base

  belongs_to :searches
  MAX_FRIENDS = 1000000
  
  def feed_entry
    begin
      entry = FeedEntry.find_by_guid(self.feed_entry_guid)
    rescue
      puts "not found" + self.feed_entry_guid.to_s
      entry = []
    end
    return entry
  end
  
  def person
    Person.find_by_username(self.twitter_username)
  end
    
  def self.collect(search_result_id, project_id)    
    result = SearchResult.find(search_result_id)    
    person = Person.collect_person(result.twitter_username, project_id, MAX_FRIENDS)
    FeedEntry.collect_entry(result.feed_entry_guid, person.id)      
  end
  
end