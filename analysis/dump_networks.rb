require '../config/environment'

members = FasterCSV.read("#{RAILS_ROOT}/analysis/data/missing_feed_entries.csv").flatten

# Create a final project and add the selected members to this project
final_project = Project.new(:name => "final")
members.each do |member|  
  person = Person.find_by_username(member)
  puts "Adding member:  #{member} to final project #{final_project.name}"
  final_project.persons << person
end
final_project.save!

#Dump the aggregated FF network
final_project.dump_FF_edgelist

#Dump the aggregated AT network
final_project.dump_AT_edgelist

#Dump the aggreagted RT neworks
final_project.dump_RT_edgelist
