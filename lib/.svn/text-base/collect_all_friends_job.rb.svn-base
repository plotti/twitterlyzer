class CollectAllFriendsJob < Struct.new(:id, :project_id)
  def perform
    person = Person.find(id)    
    print "Collecting " + person.friends_count.to_s + " friends of: " +  person.username 
    Person.collect_all_friends(person,project_id)
  end  
end