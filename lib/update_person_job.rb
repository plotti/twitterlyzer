class UpdatePersonJob < Struct.new(:twitter_id)
  def perform                
    puts "Updating person: " +  twitter_id.to_s
    Person.update_twitter_stats(twitter_id)  
  end  
end
