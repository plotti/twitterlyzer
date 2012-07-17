require '../config/environment'
require 'faster_csv'

@missing_feed_entries = File.open("data/missing_feed_entries.csv","w+")
@missing_persons = File.open("data/missing_persons.csv","w+")
@blacklist = File.open("data/blacklist.csv","w+")
@missing_friends = File.open("data/missing_friends.csv","w+")

#Read in the final Partition file
rows = FasterCSV.read("#{RAILS_ROOT}/analysis/data/partitions/final_partitions_p100_200_0.2.csv")

c = 0
i = 0
j = 0
MAX_TOLERANCE = 32

def output_missing_persons(member)
    if Person.find_by_username(member[0]) == nil
        begin
            if @@twitter.user(member[0]) != nil
              i += 1
              community = community = member[1].split("_").first
              project = Project.find_by_name(community)
              puts "#{i} Missing person #{member[0]}"
              @missing_persons.puts "#{member[0]},#{community}" #Output the missing persons  
            end
        rescue
            j+=1
            puts "#{j} Couldn't locate user #{member[0]}"
            @blacklist.puts "#{member[0]}" #Output persons which cannot be found on twitter
        end
    end    
end 

def check_zero_feed_entries(member)
    person = Person.find_by_username(member[0])
    if person.feed_entries.count == 0            
      community = member[1].split("_").first
      project = Project.find_by_name(community)
      if !person.private && person.statuses_count != 0
        begin
          if !@@twitter.user(member[0]).protected? # If the person can be found on Twitter and is not protected            
            #Update Data
            person.statuses_count = @@twitter.user(member[0]).statuses_count
            person.save!
            if person.statuses_count != 0 
                @missing_feed_entries.puts "#{member[0]}, zero_statuses" #Output persons with missing feed_entries
            end            
          else
              puts "Updating person info on person #{person.username}"
              person.private = true
              person.statuses_count = @@twitter.user(member[0]).statuses_count
              person.save!
          end
        rescue        
          puts "Couldn't locate user #{member[0]}"
          @blacklist.puts "#{member[0]}" #Output persons which cannot be found on twitter
        end
      end
    end
end

def check_missing_feed_entries(member)
    person = Person.find_by_username(member[0])
    statuses_count = person.statuses_count
    feed_entries_count = person.feed_entries.count
    if statuses_count > 3200
        delta = 3200 -feed_entries_count
    else
        delta = statuses_count - feed_entries_count
    end
    if delta > MAX_TOLERANCE
        @missing_feed_entries.puts "#{member[0]}, delta: #{delta}" #Output persons with missing feed_entries        
    end
end

def check_missing_friends_ids(member)
    person = Person.find_by_username(member[0])
    if person.friends_count != 0 && !person.private        
        if person.friends_ids.count == 0
            begin
                if !@@twitter.user(member[0]).protected?            
                    @missing_friends.puts "#{member[0]}"
                end
            rescue
                puts "Couldn't locate user #{member[0]}"
                @blacklist.puts "#{member[0]}" #Output persons which cannot be found on twitter
            end
        end
    end    
end

i = 0
rows.each do |member|
    i += 1
    puts "#{i} Working on member #{member[0]}"
    #Missing persons
    if !output_missing_persons(member)        
        #Check for 0 feed_entries
        check_zero_feed_entries(member)
        #Check for feed_entries with discrepancy between collected and existing
        check_missing_feed_entries(member)
        #Check for missing Friends IDS
        check_missing_friends_ids(member)
    end  
end

@missing_feed_entries.close
@missing_persons.close
@blacklist.close
@missing_friends.close
