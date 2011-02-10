class UpdateFeedEntriesJob < Struct.new(:id)
  def perform                
    person = Person.find(id)    
    FeedEntry.update_person_entries(person)  
  end  
end

