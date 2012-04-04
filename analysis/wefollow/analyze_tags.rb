require '../config/environment'
require 'faster_csv'
require 'text'

#This file is used to analyze the wefollow tags and group them into categories of tags that contain similar tags such as music and musiclover

in_list  = FasterCSV.read("results/all_groups_without_mine.csv")
master = in_list.select{|a| a[0].length > 2}.sort{|a,b| a[0].length <=> b[0].length}
slave = in_list.select{|a| a[0].length > 2}.sort{|a,b| a[0].length <=> b[0].length}

outfile = File.open("results/testrun.csv", 'wb')

i = 0
CSV::Writer.generate(outfile) do |csv|  
  
  processed_words = []
  collection = []
  
  master.each do |master_word|
    
    #Skip words that have been part of the duplicate finding process
    found = false
    processed_words.each do |word|
      if master_word[0].include? word #word.include? master_word[0] #or master_word[0].include? word
        found = true
      end
    end
    if found
      next
    end
    
    similar_words = []    
    similar_words << {:word => master_word[0], :members => master_word[1].to_i, :distance => 0}
  
    #puts "Working on Row #{i} lenght of word #{master_word[0].length}"
    slave.each do |slave_word|      
      similar = false
      included = false
      
      #They start with the same two letters
      if master_word[0].chars.first.downcase == slave_word[0].chars.first.downcase && master_word[0].chars.to_a[1].downcase == slave_word[0].chars.to_a[1].downcase
       
        #A Levensthein distance lower than x
        distance = Text::Levenshtein.distance(master_word[0], slave_word[0])
        if (distance > 0 && distance < 4) && master_word[0].length > 6 && slave_word[0].length > 6 #6 for long words only...
          similar = true
        end
        
        #One is included in the other 
        if master_word[0].length != slave_word[0].length
          if (master_word[0].include? slave_word[0]) or (slave_word[0].include? master_word[0])
            included = true
          end
        end
        
        if similar or included
          similar_words << {:word => slave_word[0], :members => slave_word[1].to_i, :distance => distance}
          if master_word[0].include? "entre"
            puts "For word #{master_word[0]} found similar word #{slave_word[0]}"
          end          
          processed_words << slave_word[0].downcase
        end        
      end      
    end

    #CSV Output
    collection << similar_words  
    i += 1
  end
  
  collection.sort{|a,b| b.collect{|item| item[:members]}.max <=> a.collect{|item| item[:members]}.max}.each do |row|
    output = []
    row.sort{|a,b| b[:members] <=> a[:members]}.each do |word|
      output << word[:word]
      output << word[:members]
      output << word[:distance]
    end
    csv << output
  end
end