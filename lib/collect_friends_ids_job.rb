class CollectFriendsIdsJob < Struct.new(:person_id)
  def perform
    person = Person.find(person_id)        
    person.collect_friends person.twitter_id    
  end  
end