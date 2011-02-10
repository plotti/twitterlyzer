require 'rubygems'
require 'gnuplot'
require 'uri'
require 'csv'

coorp = []
CSV.open("tasks/coorporate accounts.txt", "r") do |row|
	user = {}
	user[:name] = URI.parse(row.to_s).path.reverse.chop.reverse
	user[:mention_count] = 0
	coorp << user
end

i = 0 
outfile = File.open("1000_2000_mention_count.csv", 'wb')
CSV::Writer.generate(outfile) do |csv|
	csv << ["Person", "Mentions Company", "Tweet"]
	Project.last.persons[1000..2000].each do |person|
		i += 1
		puts "Analyzing #{i} Person #{person.username}"
		person.feed_entries.each do |entry|		
			coorp.each do |company|
				search_string = "@" + company[:name]
				if entry.text.include?(search_string)
					company[:mention_count] = company[:mention_count] + 1
					csv << [person.username, company[:name], entry.text]
				end	
			end
			
		end
	end
end

outfile2 = File.open("1000_2000_mention_results.csv", 'wb')

CSV::Writer.generate(outfile2) do |csv|
  coorp.each do |item|	  
     csv << [item[:name], item[:mention_count]]
  end
end
outfile.close
outfile2.close
  
