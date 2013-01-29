require '../config/environment'
require 'faster_csv'

members = FasterCSV.read("#{RAILS_ROOT}/analysis/data/partitions/final_partitions_p100_200_0.2.csv")
communities = members.collect{|m| m[1]}.uniq

outfile = File.open("#{RAILS_ROOT}/analysis/results/spss/group bonding/#{584}_group_bonding_cognitive.csv",'w')


CSV::Writer.generate(outfile) do |csv|
  csv << ["Community name", "Total number of tweets", "Tweets mentioning keyword", "Total persons mentioning keyword"]
end

CSV::Writer.generate(outfile) do |csv|
    communities.each do |community|
        r = {}                
        keywords = community.split("_")
        tweets = 0
        project_persons = members.collect{|m| m[0] if m[1] == community}.compact
        project_persons.each do |person|
            puts person
            Person.find_by_username(person).feed_entries.each do |tweet|
                tweets += 1
                keywords.each do |keyword|
                    if tweet.text.include? keyword
                        if r[person] == nil
                            r[person] = 1
                        else
                            r[person] += 1
                        end
                    end   
                end
            end
        end
        csv << [community, tweets, r.values.sum, r.values.count]
    end
end

outfile.close