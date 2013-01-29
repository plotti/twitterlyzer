require '../../config/environment'

members = FasterCSV.read("#{RAILS_ROOT}/analysis/data/partitions/final_partitions_p100_200_0.2.csv")
communities = members.collect{|m| m[1]}.uniq

centralities = {}
FasterCSV.read("#{RAILS_ROOT}/analysis/results/spss/individual bonding/584_individual_bonding.csv").each do |line|
  centralities[line[2]] = line[5]
end

#Get members of a certain communtiy
keyword = "chemistry"
r = []
members.each{|m| r << m[0] if m[1] == keyword }

outfile = File.open("#{RAILS_ROOT}/analysis/results/#{keyword}_messages.csv", 'wb')
CSV::Writer.generate(outfile) do |csv|
  csv << ["name", "keyword_found", "centrality", "retweets", "all_retweets"]
  r.each do |member|
    puts member
    Person.find_by_username(member).feed_entries.each do |f|
      if f.text.include?(keyword)
        keyword_found = 1
      else
        keyword_found = 0
      end
      retweets = 0
      f.retweet_ids.each do |retweet|
        if r.include? retweet[:person]
          retweets += 1
        end
      end
      csv << [member, keyword_found, centralities[member], retweets, f.retweet_ids.count]      
    end
  end
end
