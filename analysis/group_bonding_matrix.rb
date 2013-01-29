require '../config/environment'
require 'faster_csv'

members = FasterCSV.read("#{RAILS_ROOT}/analysis/data/partitions/final_partitions_p100_200_0.2.csv")
communities = members.collect{|m| m[1]}.uniq
communities = communities[0..2]

#group_csv = CSV.open("#{RAILS_ROOT}/analysis/results/spss/group bonding/#{584}_group_bonding_matrix.csv",'w')
individual_csv = CSV.open("#{RAILS_ROOT}/analysis/results/spss/individual bonding/#{584}_individual_bonding_matrix.csv",'w')

#how often did persons of community x mention keyword y
#
#                archaeology basketball  cinema
#archaeology     1234        23          12
#basketball      23          4212        2

#Write the headers for the csv files
header = ["id"] + communities
#group_csv << header
individual_csv << header
#group_result ={}
individual_result = {}

# Fill up the person ids for community
#project_persons_ids = {}
#communities.each do |community|        
#    project_persons = members.collect{|m| m[0] if m[1] == community}.compact      
#    project_persons_ids[community] = []
#    project_persons.each do |person|
#        person_id = Person.find_by_username(person).id
#        project_persons_ids[community] << person_id
#    end
#end

# Fill up individual count
members.each do |member|
    person_id = Person.find_by_username(member).id
    individual_result[person_id] = {}
    communities.each do |community|        
        individual_result[person_id][community] = 0
    end
end

communities.each do |community|                
    #group_result[community] = {}           
    #run for each keyword        
    keywords = community.split("_")                          
    keywords.each do |keyword|
        puts "started search #{keyword}"
        search = FeedEntry.search do
                fulltext keyword
                paginate :page => 1, :per_page => 1000000
        end
        puts "ended search #{search.total}"
        persons = individual_result.keys
        #communities.each do |temp_community|                
            #group_result[community][temp_community] = 0
            search.results.each do |result|                
                
                # analyze tweets individually
                if persons.include? result.person_id
                    individual_result[result.person_id][community] += 1    
                end
                
                # analyze the tweets from this community
                #if project_persons_ids[temp_community].include? result.person_id
                #    group_result[community][temp_community] += 1
                #end
            end
        #    puts "The keyword #{community} is mentioned by #{temp_community} community #{group_result[community][temp_community]} times" 
        #end
    end
    #output the aggregated group csv
    #line = [community]
    #communities.each do |tmp_community|
    #    line << group_result[community][tmp_community]
    #end
    #group_csv << line
end

#Output the individual csv
members.each do |member|
    person = Person.find_by_username(member)
    line = [person.username]
    communities.each do |tmp_community|
        line << individual_result[person.id][tmp_community]
    end
    indivdual_csv << line
end

#group_csv.close
individual_csv.close