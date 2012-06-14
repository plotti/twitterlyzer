require '../config/environment'
require 'faster_csv'

missing_feed_entries = File.open("data/missing_feed_entries.csv","w+")
missing_persons = File.open("data/missing_persons.csv","w+")
blacklist = File.open("data/blacklist.csv","w+")

#Read in the final Partition file
rows = FasterCSV.read("#{RAILS_ROOT}/analysis/data/partitions/final_partitions_p100_200_0.2.csv")

c = 0
i = 0
j = 0

rows.each do |member|
    if Person.find_by_username(member[0]) == nil
        begin
            if @@twitter.user(member[0]) != nil
              i += 1
              community = community = member[1].split("_").first
              project = Project.find_by_name(community)
              puts "#{i} Missing person #{member[0]}"
              missing_persons.puts "#{member[0]},#{community}" #Output the missing persons  
            end
        rescue
            j+=1
            puts "#{j} Couldn't locate user #{member[0]}"
            blacklist.puts "#{member[0]}" #Output persons which cannot be found on twitter
        end
    elsif Person.find_by_username(member[0]).feed_entries.count == 0            
      community = member[1].split("_").first
      project = Project.find_by_name(community)
      if !Person.find_by_username(member[0]).private && Person.find_by_username(member[0]).statuses_count != 0
        begin
          if !@@twitter.user(member[0]).protected?
            c += 1
            missing_feed_entries.puts "#{member[0]}" #Output persons with missing feed_entries
            puts "#{c} Missing Feeds for Person #{member[0]} #{project.id}"
          end
        rescue
          j+=1
          puts "#{j} Couldn't locate user #{member[0]}"
          blacklist.puts "#{member[0]}" #Output persons which cannot be found on twitter
        end
      end            
    end  
end

missing_feed_entries.close
missing_persons.close
blacklist.close
