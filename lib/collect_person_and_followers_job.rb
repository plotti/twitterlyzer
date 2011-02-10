class CollectPersonAndFollowersJob < Struct.new(:twitter_id, :project_id, :max)
  def perform    
    puts "Collecting person and followers of : " +  twitter_id.to_s
    Person.collect_person_and_followers(twitter_id,project_id,max)
  end  
end