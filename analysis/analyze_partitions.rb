require '../config/environment'
require 'faster_csv'

#This file outputs for each category how many Members from the Lists were initially found in the project
#It also checks how many members remained in the categories after the re-assignment and finally
#it checks how many double entries there are between categories (whcih should always be none)

partitions = FasterCSV.read("data/partitions.csv")
outfile = File.open("results/partition_stats.csv",'w')
outfile.puts "Project Name, Members from List found in project, Members after re-assignment, Double Entries"

sorted_members ={}
@@communities.each do |community|  
  project = Project.find(community)
  puts "Reading in project #{project.name}"
  sorted_members[project.name] = {:community => community, :list => FasterCSV.read("#{RAILS_ROOT}/data/#{project.name}_sorted_members.csv")[1..100]} #skip header  
end

groups = {}
partitions.each do |row|
	if groups[row[1]] == nil
		groups[row[1]] = []
	end
	groups[row[1]] << {:name => row[1], :place => row[2].to_i}
end

groups.each do |key,value|
	places = []
	names = []
	value.each do |e|
		places << e[:place]
	end
	double_entries = names.length - names.uniq.length
	begin
		entries = sorted_members[key]		
		persons = Project.find(entries[:community]).persons.each.collect{|p| p.username}
		count = 0	
		entries[:list].each do |member|
			if persons.include? member[0]
				count += 1
			end
		end		
		outfile.puts "#{key}, #{count}, #{places.count}, #{double_entries}"
	rescue
	end	
end

outfile.close
