require '../config/environment'
require 'faster_csv'

# This file outputs a partition of the network based on the inputs from the collected lists
# It first unites categories that share a certain percentage x of members into one category
# It then reassigns members to other lists, if they fit better 

#Define how many people we want to have maximum in  a community
PARTITION_MAX = 100

#Define how many list places should be considered
MAX = 200

#Threshold: The threshold until which the categories should be merged (e.g. 0.2 = 20 % of members are shared)
THRESHOLD = 0.2

outfile = CSV.open("data/paritions/partitions_p#{PARTITION_MAX}_#{MAX}_#{THRESHOLD}.csv", "wb")
final_partition = CSV.open("data/partitions/final_partitions_p#{PARTITION_MAX}_#{MAX}_#{THRESHOLD}.csv", "wb")
outfile << ["Name","Original Category", "Original Category Place", "Assigned Category", "Assigned Category Place", "Competing Categories", "Details"]

members ={}
@@communities.each do |community|  
  project = Project.find(community)
  puts "Reading in project #{project.name}"
  rows = FasterCSV.read("#{RAILS_ROOT}/data/#{project.name}_sorted_members.csv")[1..MAX] #skip header
  i,r = 0,{}
  rows.each do |member|
    i += 1
    r[member[0]] = {:rank => i, :count => member[2].to_i} if !BLACKLIST.include?(member[0])
  end
  members[project.name] = r
end

merged = {}
#First step should be to unite partitions that have a high overlap of members
@@communities.each do |community|
  project = Project.find(community)    
  #puts "Checking merge on project id: #{community}"
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
    puts "Merged #{project.name} with #{max_group}"
    merged_name = "#{project.name}_#{max_group}"
    h = {}
    
    # Add the counts and merge the members
    merged_members = (members[project.name].keys + members[max_group].keys).uniq
    merged_members.each do |member|
      count1 = members[project.name][member][:count] rescue 0
      count2 = members[max_group][member][:count] rescue 0
      h[member] = {:rank => 0 , :count => count1+count2}
    end
    members[merged_name] = h
    
    #Recalculate the ranking for faster lookup
    sorted_members = members[merged_name].sort{|a,b| b[1][:count]<=>a[1][:count]}.collect{|a| a[0]}
    members[merged_name].keys.each do |member|
      members[merged_name][member][:rank] = sorted_members.index(member)+1
    end
    
    #Take only the first x members since the categories will grow
    members[merged_name] = Hash[members[merged_name].sort{|a,b| b[1][:count]<=>a[1][:count]}[0..MAX]]
    
    #Point where the merged group is stored
    [project.name,max_group].each do |entry|
      members.delete(entry)
      merged[entry] = merged_name
      merged.each do |key,value|
        if value == entry
          merged[key] = merged_name
        end
      end
    end
  end
end

#Delete the groups that we merged
merged.keys.each do |key|
  members.delete(key)
end

#Second step is to output the final partitions according to the ranking of the persons in their groups
seen_persons = []
final_candidates = {}
seen_projects = []
@@communities.each do |community|
  project = Project.find(community)      
  if merged[project.name] == nil
    project_members = members[project.name]
    project_name = project.name
  else    
    project_members = members[merged[project.name]]
    project_name = merged[project.name]
  end
  if !seen_projects.include? project_name
    puts "Computing places on project name: #{project_name}"
    seen_projects << project_name
  else
    puts "Skippng #{project_name}"
    next 
  end  
  project_members.each do |person|    
    if !seen_persons.include? person[0]
      #puts "Working on person #{person[0]}"
      min_list_place,original_list_place,membership,memberships = 10000,0,"",[]                   
      members.each do |key,value|
        if merged[key] != nil
          next
        end
        if value[person[0]] != nil # we have found a matching person in the lists
          memberships += [key,value[person[0]][:rank]]
          original_list_place = value[person[0]][:rank] if key == project_name
          membership, min_list_place = key,value[person[0]][:rank] if value[person[0]][:rank] < min_list_place
        end        
      end      
      seen_persons << person[0]
      outfile << [person[0], project_name, original_list_place, membership, min_list_place, memberships.count/2, memberships.join(",")]
      final_candidates[membership] ||= []
      final_candidates[membership] << {:name => person[0], :rank => min_list_place, :competing_memberships => memberships.count/2}
    end      
  end 
end

#Output the final partition
final_candidates.each do |key,value|  
  value.sort{|a,b| a[:rank]<=>b[:rank]}[0..PARTITION_MAX].each do |member|
    final_partition << [member[:name],key,member[:rank],member[:competing_memberships]]
  end   
end

outfile.close
