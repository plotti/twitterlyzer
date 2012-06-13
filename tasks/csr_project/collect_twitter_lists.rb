  require 'rubygems'  
  require 'csv'

  twitter_ids = []
  words = []
  csv_file = "csr_persons.csv"
  
  CSV::Reader.parse(File.open(csv_file, 'rb')) do |row  |
    result = URI.parse(row.to_s).path.reverse.chop.reverse
    puts result
    twitter_ids <<  result
  end

  i = 0 
  twitter_ids.each do |entry|      
    i += 1
    puts "PERSON #{i}"
    #enter own lists
    begin
      Person.collect_own_lists(entry)
    rescue
      puts "No OwnLists found for this Person: #{entry}"        
    end
    
    #subscribed lists
    begin
      Person.collect_list_subscriptions(entry)
    rescue
      puts "No Subscribed Lists found for this Person: #{entry}"        
    end
    
    #member lists
    begin
      Person.collect_list_memberships(entry)
    rescue
      puts "No MemberLists found for this Person: #{entry}"        
    end 
  end

  #get unique results
  results = List.all.uniq_by{|h| h.uri}  
  
  #apply keyword filtering
  white_file = "white.txt"
  whitelist = []
  filtered = []
  
  CSV::Reader.parse(File.open(white_file, 'rb')) do |row  |
    whitelist << row.to_s
  end
  
  #apply whitelist
  results.each do |result|
    whitelist.each do |word|
      if result.name.downcase.include?(word)
        filtered << result
        break
      end
    end    
  end
  
  i = 0
  filtered.each do |entry|
    i += 1
    puts "Working on entry: #{i} of #{filtered.length}"
    begin
      Person.collect_list_members(entry.username, entry.slug,9)
    rescue
      puts "Couldnt collect persons of list #{entry.uri}"
    end
  end
