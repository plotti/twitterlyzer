require '../config/environment'

outfile = File.open("analysis/results/communities_stats.csv",'w')

CSV::Writer.generate(outfile) do |csv|
  csv << ["Community ID", "Name", "List ID", "List Name", "Number of Lists", "Number of Persons", "Number of Private Persons", "Number of deleted Persons", "Number of Persons without Tweets", "Number of Tweets", "Number of Retweets"]  
end

CSV::Writer.generate(outfile) do |csv|
  @@communities.each do |community|
    project = Project.find(community)
    project_lists = Project.find_by_name(projct.name+"lists")    
    private_persons = 0
    project_tweets = 0
    persons_without_tweets = 0
    persons_deleted = 0
    
    project.persons.each do |person|
    
      # Check Persons    
      if person.private
        private_persons += 1
      end
            
      # Check Tweets
      project_tweets += person.feed_entries.count
      if person.feed_entries.count == 0
        # For persons without tweets check if they are deleted
        begin
          person = @@twitter.user(person.username)
        rescue
          person = ""
        end
        if person != ""
          persons_without_tweets += 1
        else
          persons_deleted += 1
        end
        
      end
      
      # Check Retweets
      person_retweets = 0
      person.feed_entries.each do |f|
        person_retweets += f.retweet_ids.count
      end
      person.d1 = person_retweets
      person.save!
    end
  csv << [project.id, project.name, project_lists.id, project_lists.name, project_lists.lists.count, project.persons.count, private_persons, ]
  end
  
end




