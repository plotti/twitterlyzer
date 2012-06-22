require '../config/environment'

members = FasterCSV.read("#{RAILS_ROOT}/analysis/data/partitions/final_partitions_p100_200_0.2.csv")

# Create a final project and add the selected members to this project
final_project = Project.new(:name => "final")
members.each do |member|
  begin
    person = Person.find_by_username(member[0])
    #puts "Adding member:  #{member[0]} to final project."
    final_project.persons << person  
  rescue
    puts "Could not add person #{member[0]}"
  end
end
final_project.save!

# TODO missing:
# rogerzare 
# SenSanders

#Dump the aggregated FF network
#final_project.dump_FF_edgelist

#Dump the aggregated AT network
#final_project.dump_AT_edgelist

#Dump the aggreagted RT neworks
#final_project.dump_RT_edgelist

