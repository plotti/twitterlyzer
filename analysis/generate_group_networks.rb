require '../config/environment'

@@communities.each do |community|
  p = Project.find(community)
  puts "working on project id:  #{community}"
  p.dump_all_networks
end
