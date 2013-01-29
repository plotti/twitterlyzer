require '../config/environment'
require 'faster_csv'

members = FasterCSV.read("#{RAILS_ROOT}/analysis/data/partitions/final_partitions_p100_200_0.2.csv")
lookup = FasterCSV.read("#{RAILS_ROOT}/analysis/data/lookup_table/lookup.csv")
lookup_map = Hash[lookup.map{|sym| [sym[0], sym[1..20]]}]

communities = members.collect{|m| m[1]}.uniq
communities = communities
outfile = File.open("#{RAILS_ROOT}/analysis/results/spss/individual bonding/#{584}_individual_bonding_matrix.csv",'w')

#how often did persons of community x mention keyword y
#
#                archaeology basketball  cinema
#individual1     1234        23          12
#individual2     23          4212        2
#...

individual_result = {}

# Fill up individual count
members.each do |member|
    person_id = Person.find_by_username(member[0]).id
    individual_result[person_id] = {}
    communities.each do |community|        
        individual_result[person_id][community] = 0
    end
end

communities.each do |community|                
    
    #run lookup for each keyword        
    keywords = lookup_map[community]
    
    keywords.each do |keyword|
        puts "#{Time.now} #{community}: Started search for #{keyword}"
        search = FeedEntry.search do
                fulltext keyword
                paginate :page => 1, :per_page => 1000000
        end
        puts "#{Time.now}: #{community}: Ended search #{search.total}"
        persons = individual_result.keys
        search.results.each do |result|                            
            # analyze tweets individually
            if persons.include? result.person_id
                individual_result[result.person_id][community] += 1    
            end
        end
    end
end

#Output the individual csv
CSV::Writer.generate(outfile) do |csv|
    header = ["id","community"] + communities
    csv << header
    members.each do |member|
        person = Person.find_by_username(member[0])
        line = [person.username,member[1]]
        communities.each do |tmp_community|
            line << individual_result[person.id][tmp_community]
        end
        csv << line
    end
end

outfile.close


# Summarize

result = FasterCSV.read("#{RAILS_ROOT}/analysis/results/spss/individual bonding/#{584}_individual_bonding_matrix.csv")
outfile = File.open("#{RAILS_ROOT}/analysis/results/spss/individual bonding/final_#{584}_individual_bonding_matrix.csv",'w')
outfile2 = File.open("#{RAILS_ROOT}/analysis/results/spss/group bonding/final_#{584}_group_bonding_matrix.csv",'w')

#Individual
CSV::Writer.generate(outfile) do |csv|
    header = result.first
    i = 0
    result.each do |line|
        if i == 0
            out = ["Own_Keywords", "Other_keywords"] + line
            csv << out
        else        
            own_keywords = result[i][header.index(line[1])]
            other_keywords = result[i][3..1000].collect{|element| element.to_i}.sum
            out = [own_keywords, other_keywords] + line
            csv << out
        end
        i += 1
    end
end
outfile.close

CSV::Writer.generate(outfile) do |csv|

end

#group
