#This file outputs overviews on the community level

require '../config/environment'

outfile = File.open("#{RAILS_ROOT}/analysis/results/stats/communities_stats.csv",'w')

#Decide on a final partition
members = FasterCSV.read("#{RAILS_ROOT}/analysis/data/partitions/final_partitions_p100_200_0.2.csv")
communities = members.collect{|m| m[1]}.uniq

CSV::Writer.generate(outfile) do |csv|
  csv << ["Community ID", "Name", "List ID", "List Name", "Number of Lists", "Number of Persons", "Number of Private Persons", "Number of deleted Persons", "Number of Persons without Tweets", "Number of Tweets", "Number of Retweets"]  
end

CSV::Writer.generate(outfile) do |csv|
  communities.each do |community|    
    #Check the underlying projects
    community.split("_").each do |sub_community|
      puts "Working on #{sub_community}"
      private_persons = 0
      project_tweets = 0
      project_retweets = 0
      persons_without_tweets = 0
      persons_deleted = 0
      consisting_projects = community.split("_").count      
      project_lists_ids = []
      project_lists_names = []
      project_lists_counts =[]
      
      # Get the list details on the projects
      project = Project.find_by_name(sub_community)            
      begin
        project_list = Project.find_by_name(project.name+"lists")        
        project_lists_ids << project_list.id
        project_lists_names << project_list.name
        project_lists_counts << project_list.lists.count
      rescue      
        project_lists_ids << "NaN"
        project_lists_names << "NaN"
        project_lists_counts << "NaN"
      end
      
      # Collect all persons that belong to a project    
      project_persons = members.collect{|m| m[0] if m[1] == community}.compact      
      project_persons.each do |p|        
        person = Person.find_by_username(p)        
        # Check Persons    
        if person.private
          private_persons += 1
        end              
        # Check Tweets
        project_tweets += person.feed_entries.count        
        #Check deleted_persons and persons without tweets
        if person.feed_entries.count == 0
          if person.d2 == "deleted"
            persons_deleted += 1          
          else
            persons_without_tweets += 1
          end        
        end        
        # Add up Retweets of all persons
        if person.d1 != nil
          project_retweets += person.d1
        else
          project_retweets += 0
        end        
      end
      csv << [project.id, project.name, project_lists_ids.join(","), project_lists_names.join(","), project_lists_counts.join(","),
              project.persons.count, private_persons, persons_deleted, persons_without_tweets, project_tweets, project_retweets]
    end
  end  
end




