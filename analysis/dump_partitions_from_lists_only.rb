require '../config/environment'
require 'faster_csv'

# This file outputs a partition of the network based on the inputs from the collected lists
# It first unites categories that share a certain percentage x of members into one category
# It then reassigns members to other lists, if they fit better 

#Define how many list places should be considered
MAX = 200

#Threshold: The threshold until which the categories should be merged (e.g. 0.2 = 20 % of members are shared)
THRESHOLD = 0.2

outfile = CSV.open("data/partitions#{MAX}_#{THRESHOLD}.csv", "wb")
outfile << ["Name","Original Category", "Original Category Place", "Assigned Category", "Assigned Category Place", "Competing Categories", "Details"]

members ={}
@@communities.each do |community|  
  project = Project.find(community)
  puts "Reading in project #{project.name}"
  rows = FasterCSV.read("#{RAILS_ROOT}/data/#{project.name}_sorted_members.csv")[1..MAX] #skip header
  i,r = 0,{}
  rows.each do |member|
    i += 1
    r[member[0]] = {:rank => i, :count => member[2].to_i}
  end
  members[project.name] = r
end

merged = {}
#First step should be to unite partitions that have a high overlap of members
@@communities.each do |community|
  project = Project.find(community)    
  puts "Checking merge on project id: #{community}"
  max_overlap_count,overlap_groups_count,overlap_groups,max_group = 0,0,[],""
  members.each do |key,value|
    if key != project.name && merged[project.name] == nil
      overlap_count = (value.keys & members[project.name].keys).count  #count how many members they have in common  don't compare with yourself            
      if overlap_count > max_overlap_count        
        max_overlap_count, max_group = overlap_count, key
      end
    end
  end
  if max_overlap_count > MAX*THRESHOLD    
    members[project.name].keys.each do |member|
      if members[max_group][member] != nil        
        members[project.name][member][:count] += members[max_group][member][:count]
      end      
    end    
    #Recalculate the ranking for faster lookup
    sorted_members = members[project.name].sort{|a,b| b[1][:count]<=>a[1][:count]}.collect{|a| a[0]}
    members[project.name].keys.each do |member|
      members[project.name][member][:rank] = sorted_members.index(member)+1
    end
    puts "Merged #{project.name} with #{max_group}"
    members["#{project.name}_#{max_group}"] = members[project.name]
    members.delete(project.name)
    members.delete(max_group)
    merged[project.name] = "#{project.name}_#{max_group}"
    merged[max_group] = "#{project.name}_#{max_group}"   
  end
end

#Delete the groups that we merged
merged.keys.each do |key|
  members.delete(key)
end

#Second step is to output the final partitions according to the ranking of the persons in their groups
seen_persons = []
@@communities.each do |community|
  project = Project.find(community)    
  puts "Working on project name: #{project.name}"  
  if merged[project.name] == nil
    sorted_members = members[project.name].sort{|a,b| b[1][:count]<=>a[1][:count]}.collect{|a| a[0]}
    project_name = project.name
  else
    sorted_members = members[merged[project.name]].sort{|a,b| b[1][:count]<=>a[1][:count]}.collect{|a| a[0]}
    project_name = merged[project.name]
  end  
  sorted_members.each do |person|      
    if !seen_persons.include? person        
      list_place,original_list_place,membership,memberships = 10000,0,"",[]       
      members.each do |key,value|
        if merged[key] != nil
          next
        end
        list = value.sort{|a,b| b[1][:count]<=>a[1][:count]}.collect{|a| a[0]}
        i = 0
        list.each do |member|            
          i += 1
          if member == person            
            memberships += [key,i] # note the membership of the person and the place on the list            
            original_list_place = i if key == project_name                   
            membership, list_place= key,i if i < list_place                           
          end
        end
      end
      seen_persons << person
      outfile << [person, project_name, original_list_place, membership, list_place, memberships.count/2, memberships.join(",")]
    end      
  end
end

outfile.close
