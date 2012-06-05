require 'rubygems'
require 'faster_csv'

partitions = FasterCSV.read("data/partitions.csv")
outfile = File.open("results/partition_stats.csv",'w')

groups = {}
partitions.each do |row|
	if groups[row[1]] == nil
		groups[row[1]] = []
	end
	groups[row[1]] << {:name => row[1], :place => row[2].to_i}
end

groups.each do |key,value|
	places = []
	value.each do |e|
		places << e[:place]
	end
	missing = (1..99).to_a-places
	outfile.puts "Name: #{key}, Members:#{places.count}, :Places:#{missing.join(',')}"
end

outfile.close
