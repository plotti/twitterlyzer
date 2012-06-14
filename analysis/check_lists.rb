# This file outputs distribution graphs of the underlying lists

require '../config/environment'
require 'faster_csv'

thresholds = [1000,100,10]
positions =  [1,50,100,200,1000]

#Decide on a final partition
members = FasterCSV.read("#{RAILS_ROOT}/analysis/data/partitions/final_partitions_p100_200_0.2.csv")
communities = members.collect{|m| m[1]}.uniq

outfile = File.open("#{RAILS_ROOT}/analysis/results/stats/lists_stats.csv",'w')

CSV::Writer.generate(outfile) do |csv|
  csv << ["Community name", "Based on Projects", "# lists", "Total unique members on all lists"]
end

CSV::Writer.generate(outfile) do |csv|
  communities.each do |community|
    lists_count = []
    total_members = 0
    projects = []
    community.split("_").each do |sub_community|
      
      puts "Working on #{sub_community}"
      project = Project.find_by_name(sub_community)
      projects << project.name
      
      begin
        lists = Project.find_all_by_name(project.name+"lists").last.lists # if we happen to have two take the last one
        lists_count << lists.count
      rescue        
        lists_count << "NaN"
      end      
      
      sorted_members  = FasterCSV.read("#{RAILS_ROOT}/data/#{project.name}_sorted_members.csv")
      rankings =  Array.new(1000,0)
      
      i = -1 # skip header
      sorted_members.each do |member|
        total_members << member[0]
        i += 1
        #Plot the first 1000 # of Listings
        #Save the 1000 first ranks
        if i < 1000
          rankings[i-1] = member[2]          
        end
        Gnuplot.open { |gp|
          Gnuplot::Plot.new( gp ) { |plot|
            plot.terminal "png"
            plot.output "#{RAILS_ROOT}/analysis/results/graphs/#{project.name}.png"
            plot.title  "Listings for #{project.name}"
            plot.ylabel "# of Listings"
            plot.xlabel "Place"
            plot.data << Gnuplot::DataSet.new([(1..999).to_a, rankings]) { |ds|
              ds.with = "lines"
              ds.linewidth = 4
            }
          }
        }
      end
    end        
    csv  <<[ community, projects.join(","), lists_count.join(","), total_members.uniq.count]
  end
end

outfile.close