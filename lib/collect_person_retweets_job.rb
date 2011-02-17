class CollectPersonRetweetsJob < Struct.new(:id)
  def perform
    person = Person.find(id)
    FeedEntry.collect_retweet_ids_for_person(person)
  end  
end

