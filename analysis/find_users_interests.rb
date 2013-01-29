require '../config/environment'

interests = {}
rows = FasterCSV.read("#{RAILS_ROOT}/analysis/data/partitions/final_partitions_p100_200_0.2.csv")
rows.each do |row|
  interests[row[0]] = {:category => row[1], :count => row[2]}
end

project = Project.last
ids = project.persons.collect{|p| p.twitter_id}

name = "burnedshop"
Person.collect_person(name,2,100000,"",true,true)
origin = Person.find_by_username(name)
origin.follower_ids.each do |friend|
  puts "Collecting #{friend}"
  if Person.find_by_twitter_id(friend) == nil
    Person.collect_person(friend,2,100000)  
  end
end

names = {}
i = 0
ids.each do |id|
  i+=1
  puts i 
  names[id] = Person.find_by_twitter_id(id).username
end

out = []
out2 = []
i = 0
origin.follower_ids.each do |id|    
    person = Person.find_by_twitter_id(id)
    i += 1
    puts i
    person.friends_ids.each do |id|
      if ids.include? id        
        out << [names[id],interests[names[id]][:category]] #id
        out2 << id
      end      
    end
end

##### Individual output #######

outfile = File.open("#{RAILS_ROOT}/analysis/results/#{name}_single_interests.csv", 'wb')
CSV::Writer.generate(outfile) do |csv|  
  out.each do |row|
    csv << [row[0],row[1]]  
  end
end

#### Aggreagted output ########

personal_interests = {}
out2.each do |id|  
  interest = interests[Person.find_by_twitter_id(id).username]
  if interest != nil
    if personal_interests[interest[:category]] == nil
      personal_interests[interest[:category]] = {:count => 1, :names => []}
      personal_interests[interest[:category]][:names] << [Person.find_by_twitter_id(id).username, interest[:count]]
    else
      personal_interests[interest[:category]][:count] += 1
      personal_interests[interest[:category]][:names] << [Person.find_by_twitter_id(id).username, interest[:count]]
    end
  end
end

personal_interests.sort{|a,b| b[1][:count] <=> a[1][:count]}
outfile = File.open("#{RAILS_ROOT}/analysis/results/interests/#{name}_grouped_interests.csv", 'wb')
CSV::Writer.generate(outfile) do |csv|  
  personal_interests.collect{|p| [p[0],p[1][:count]]}.sort{|a,b| b[1]<=>a[1]}.each do |k,v|
    csv << [k,v]  
  end
end