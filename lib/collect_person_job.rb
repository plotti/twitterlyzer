class CollectPersonJob < Struct.new(:twitter_id, :project_id, :max, :category)
  def perform    
    puts "Collecting person: " +  twitter_id.to_s
    Person.collect_person(twitter_id,project_id,max, category)
  end  
end