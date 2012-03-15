require '../config/environment'

outfile = File.open("analysis/results/person_stats.csv",'w')

CSV::Writer.generate(outfile) do |csv|
  csv << ["Person ID", "Person Name", "Private?", "Number of Tweets", "Number of Retweets", "Friends Count", "Followers Count", "Statuses Count"]  
end

CSV::Writer.generate(outfile) do |csv|
  @@communities.each do |community|
    project = Project.find(community)
    retweets = 0 
    project.persons.each do |person|
      if person.feed_entries.count == 0
        # For persons without tweets check if they have been deleted by Twitter
        begin
          status = @@twitter.user(person.username)
        rescue
          status = ""
        end
      end      
      if status == ""
        person.d2 = "deleted"
        person.save!
      end
      
      #Check Retweets
      person.feed_entries.each do |entry|
        retweets += entry.retweet_ids.count
      end
      person.d1 = retweets
      person.save!
      
    csv << [person.id, person.username, person.private, person.feed_entries.count, retweets, person.friends_count, person.followers_count, person.statuses_count]
    end    
  end
end