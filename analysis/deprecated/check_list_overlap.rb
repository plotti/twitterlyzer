require '../config/environment'
require 'faster_csv'
# deprecated since dump_partitions_from list optimizes the lists accoring to overlap

MAX = 1000
outfile = File.open("results/list_overlap#{MAX}.csv", "w+")
netfile = File.open("results/overlap_net#{MAX}.csv", "w+")
CSV::Writer.generate(outfile) do |csv|
  csv << ["Name of List A","Name of List B", "Maximum Overlapping people", "Number of 10% overlaps with other groups", "Details"]
end

sorted_members ={}
@@communities.each do |community|  
  project = Project.find(community)
  puts "Reading in project #{project.name}"
  members = FasterCSV.read("#{RAILS_ROOT}/data/#{project.name}_sorted_members.csv")[1..MAX] #skip header
  sorted_members[project.name] = members.collect{|m| m[0]}
end

CSV::Writer.generate(netfile) do |net|
  CSV::Writer.generate(outfile) do |csv|
    seen_persons = []
    @@communities.each do |community|
      project = Project.find(community)    
      puts "Working on project id: #{community}"
      max_overlap_count = 0
      max_group = ""
      overlap_groups = []
      overlap_groups_count = 0
      sorted_members.each do |key,members|      
        if key != project.name        
          overlap_count = (members & sorted_members[project.name]).count
          #puts "#{project.name} Key: #{key} #{overlap_count} #{members.count} #{sorted_members[project.name].count}"
          if overlap_count >  MAX/10
            overlap_groups_count += 1
            overlap_groups += [key,overlap_count]
            net << [project.name, key, overlap_count]
          end
          if overlap_count > max_overlap_count
            max_overlap_count = overlap_count
            max_group = key
          end
        end            
      end
      csv << [project.name, max_group, max_overlap_count, overlap_groups_count, overlap_groups.join(",")]
    end
  end
end