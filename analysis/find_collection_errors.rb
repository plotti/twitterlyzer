require '../config/environment'
require 'faster_csv'

missing_feed_entries = File.open("results/missing_feed_entries.csv","w+")
missing_persons = File.open("results/missng_persons.csv","w+")
blacklist = File.open("results/blacklist.csv","w+")


#sorted_members ={}
#@@communities.each do |community|  
#  project = Project.find(community)
#  puts "Reading in project #{project.name}"
#  sorted_members[project.name] = {:community => community, :list => FasterCSV.read("#{RAILS_ROOT}/data/#{project.name}_sorted_members.csv")[1..100]} #skip header  
#end

rows = FasterCSV.read("#{RAILS_ROOT}/analysis/data/final_partitions200_0.2.csv")
c = 0
i = 0
j = 0
maxfriends = 100000
category = ""

rows.each do |member|
    if Person.find_by_username(member[0]) == nil
      if @@twitter.user(member[0]) != nil
        i += 1
        puts "#{i} Missing person #{member[0]}"
        community = community = member[1].split("_").first
        project = Project.find_by_name(community)
        missing_persons.puts "#{member[0]}"        
      end
    elsif Person.find_by_username(member[0]).feed_entries.count == 0            
      community = member[1].split("_").first
      project = Project.find_by_name(community)
      if !Person.find_by_username(member[0]).private && Person.find_by_username(member[0]).statuses_count != 0
        begin
          if !@@twitter.user(member[0]).protected?
            c += 1
            missing_feed_entries.puts "#{member[0]}"
            puts "#{c} Missing Feeds for Person #{member[0]} #{project.id}"
          end
        rescue
          j+=1
          puts "#{j} Couldn't locate user #{member[0]}"
          blacklist.puts "#{member[0]}"
        end
      end            
    end  
end

missing_persons.close
blacklist.close
