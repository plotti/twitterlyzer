require '../config/environment'

outfile = File.open("#{RAILS_ROOT}/analysis/results/stats/person_stats.csv",'w')

CSV::Writer.generate(outfile) do |csv|
  csv << ["Person ID", "Person Name", "Private?", "Statuses Count", "Number of Tweets", "Number of Retweets", "Retweet Count", "Friends Count", "Friends_IDS", "Followers Count", ]  
end

CSV::Writer.generate(outfile) do |csv|
  @@communities.each do |community|
    project = Project.find(community)
    puts "Working on project #{project.name}"
    retweets = 0
    retweet_count = 0
    
    project.persons.each do |person|
      
      #Check Feed Entries
      if person.feed_entries.count == 0
        # For persons without tweets check if they have been deleted by Twitter
        begin
          if Project.get_remaining_hits != "timeout"
            status = @@twitter.user(person.username)
          end          
        rescue
          status = ""
        end
        
        if status == ""
          person.d2 = "deleted"
          person.save!
        end
      end
      
      
      #Check Retweets
      if person.d1 == nil # Check only persons that we haven't checked before.
        retweets = person.feed_entries.inject(0){|r,f| r+=f.retweet_ids.count}
        retweet_count = person.feed_entries.inject(0){|r,f| r+=f.retweet_count.to_i}
        person.feed_entries.each do |entry|
          retweets += entry.retweet_ids.count
          retweet_count += entry.retweet_count.to_i
        end
        person.d1 = retweets
        person.save!        
      end
      
    csv << [person.id, person.username, person.private, person.statuses_count, person.feed_entries.count, retweets, retweet_count, person.friends_count, person.friends_ids.count, person.followers_count]
    end    
  end
end