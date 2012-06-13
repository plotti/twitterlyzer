require '../config/environment'

outfile = File.open("analysis/results/stats/communities_stats.csv",'w')

CSV::Writer.generate(outfile) do |csv|
  csv << ["Community ID", "Name", "List ID", "List Name", "Number of Lists", "Number of Persons", "Number of Private Persons", "Number of deleted Persons", "Number of Persons without Tweets", "Number of Tweets", "Number of Retweets"]  
end

CSV::Writer.generate(outfile) do |csv|
  @@communities.each do |community|
    project = Project.find(community)
    begin
      project_lists = Project.find_by_name(projct.name+"lists")
      project_lists_id = project_lists.id
      project_lists_name = project_lists.name
      project_lists_count = project_lists.lists.count
    rescue
      project_lists = "NaN"
      project_lists_id = "NaN"
      project_lists_name = "NaN"
      project_lists_count = "NaN"
    end
    
    private_persons = 0
    project_tweets = 0
    project_retweets = 0
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
        if person.d2 == "deleted"
          persons_deleted += 1          
        else
          persons_without_tweets += 1
        end
        
      end
      
      # Add up Retweets
      if person.d1 != nil
        project_retweets += person.d1
      else
        project_retweets = "NaN"
      end      

    end
  csv << [project.id, project.name, project_lists_id, project_lists_name, project_lists_count, project.persons.count, private_persons, persons_deleted,persons_without_tweets, project_tweets, project_retweets]
  end
  
end




