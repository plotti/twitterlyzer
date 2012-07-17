require '../config/environment'


members = FasterCSV.read("#{RAILS_ROOT}/analysis/data/partitions/final_partitions_p100_200_0.2.csv")
outfile = CSV.open("#{RAILS_ROOT}/analysis/data/partitions/final_partitions_p100_200_0.2_fixed.csv", "wb")

members.each do |member|
  person = Person.find_by_username(member[0])
  outfile << [person.username, member[1],member[2],member[3]]
end

outfile.close