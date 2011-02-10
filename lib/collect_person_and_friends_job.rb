class CollectPersonAndFriendsJob < Struct.new(:twitter_id, :project_id, :max)
  def perform    
    puts "Collecting person and friends of : " +  twitter_id.to_s
    Person.collect_person_and_friends(twitter_id,project_id,max)
  end  
end