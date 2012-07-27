require '../config/environment'

interests = {}
rows = FasterCSV.read("#{RAILS_ROOT}/analysis/data/partitions/final_partitions_p100_200_0.2.csv")
rows.each do |row|
  interests[row[0]] = {:category => row[1], :count => row[2]}
end

project = Project.last
ids = project.persons.collect{|p| p.twitter_id}

name = "arnicas"
Person.collect_person(name,2,100000)
person = Person.find_by_username(name)

out = []
person.friends_ids.each do |id|
    if ids.include? id
        out << id
    end
end

personal_interests = {}
out.each do |id|
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

#personal_interests.sort{|a,b| b[1][:count] <=> a[1][:count]}
puts "Name: #{name} Interests: #{personal_interests.collect{|p| [p[0],p[1][:count]]}.sort{|a,b| b[1]<=>a[1]}.join(" ")}"
