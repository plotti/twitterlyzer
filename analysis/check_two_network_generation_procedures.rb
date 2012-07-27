require '../config/environment'

project = Project.find_by_name("ruby")
outfile = CSV.open("#{RAILS_ROOT}/analysis/data/test_#{project.id}_connections.csv", "wb")

#####################CHECK AT NETWORKS BY EXAMPLE #######################

at_net_2 = project.find_at_connections
at_net_1 = project.find_solr_at_connections

solr_at_connections = FasterCSV.read("#{RAILS_ROOT}/analysis/data/solr_#{project.id}_at_connections.csv")
normal_at_connections = FasterCSV.read("#{RAILS_ROOT}/analysis/data/normal_#{project.id}_at_connections.csv")

#Entries that are in Normal but are missing in Solr
normal_matching = []
normal_missing = [] #Save the entries that yielded the differences
normal_at_connections.each do |normal_output|
  if solr_at_connections.include? normal_output
    normal_matching << normal_output
  else
    normal_missing << normal_output
  end
end

#Entries that are in Solr but are missing in Normal
solr_matching = []
solr_missing = [] #Save the entries that yielded the differences
solr_at_connections.each do |solr_output|
  if normal_at_connections.include? solr_output
    solr_matching << solr_output
  else
    solr_missing << solr_output
  end
end

outfile << ["##################### AT CONNECTIONS #############################################"]
outfile << [ "AT connections that are found in normal but missing in solr #{normal_missing.count}"]
outfile << ["AT connections that are found in solr but missing in normal #{solr_missing.count}"]
outfile << [ "AT connections that are found in both #{normal_matching.count}"]

#Get some outputs on the biggest differences in the networks
missing_entries = []
matching_entries = []
non_matching_entries = []
at_net_1.each do |triple|
    index = at_net_2.collect{|a| [a[0],a[1]]}.index([triple[0],triple[1]])
    if index == nil
      missing_entries << triple
    else
      delta = triple[2] - at_net_2[index][2]      
      if delta != 0
        non_matching_entries << [triple,delta]      
      else
        matching_entries << triple
      end      
    end
end

#Sort in reverse order highest difference first
non_matching_entries.sort!{|a,b|b[1]  <=> a[1]}
non_matching_entries[0..10].each do |entry|
  outfile << [entry[0].join(",")]
end

#####################CHECK RT NETWORKS BY EXAMPLE #######################

rt_net_1 = project.find_solr_rt_connections
rt_net_2 = project.find_rt_connections

solr_rt_connections = FasterCSV.read("#{RAILS_ROOT}/analysis/data/solr_#{project.id}_rt_connections.csv")
normal_rt_connections = FasterCSV.read("#{RAILS_ROOT}/analysis/data/normal_#{project.id}_rt_connections.csv")

#Entries that are in Normal but are missing in Solr
normal_matching = []
normal_missing = [] #Save the entries that yielded the differences
normal_rt_connections.each do |normal_output|
  if solr_rt_connections.include? normal_output
    normal_matching << normal_output
  else
    normal_missing << normal_output
  end
end

#Entries that are in Solr but are missing in Normal
solr_matching = []
solr_missing = [] #Save the entries that yielded the differences
solr_rt_connections.each do |solr_output|
  if normal_rt_connections.include? solr_output
    solr_matching << solr_output
  else
    solr_missing << solr_output
  end
end

outfile << [ "##################### RT CONNECTIONS #############################################"]
outfile << [ "RT connections that are found in normal but missing in solr #{normal_missing.count}"]
outfile << [ "RT connections that are found in solr but missing in normal #{solr_missing.count}"]
outfile << [ "RT connections that are found in both #{normal_matching.count}"]
outfile.close