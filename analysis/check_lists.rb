# This file outputs distribution graphs of the underlying lists

require '../config/environment'
require 'faster_csv'

#Decide on a final partition
members = FasterCSV.read("#{RAILS_ROOT}/analysis/data/partitions/final_partitions_p100_200_0.2.csv")
project = 584

if ARGV[0] == nil
  communities = members.collect{|m| m[1]}.uniq
else
  communities = ARGV[0]
end

outfile = File.open("#{RAILS_ROOT}/analysis/results/stats/#{584}_lists_stats.csv",'w')

CSV::Writer.generate(outfile) do |csv|
  csv << ["Community name", "Based on Projects", "# lists", "Total unique members on all lists", "Average users per list", "Min users", "Max users"]
end

skip = ["archaeology", "java", "liberal", "horror", "astronomy_physics", "highered", "parenting", "nature", "marketing", "surfing", "wedding", "magician", "hospitality", "jazz", "meditation", "piano", "wrestling", "blogs", "marriage", "lesbian", "climbing", "engineering", "finance_economics", "tennis", "tech"]


CSV::Writer.generate(outfile) do |csv|
  communities.each do |community|
    
    #skip stuff that is already computed
    if skip.include? community
      next
    end
    
    lists_count = []
    total_members = []
    projects = []
    max_users = 0
    min_users = 1000
    average = []
    total_average = 0
    
    community.split("_").each do |sub_community|
      valid_lists = 0  
      project = Project.find_by_name(sub_community)
      projects << project.name          
      project_lists = Project.find_all_by_name(project.name+"lists").last.lists # if we happen to have two projects with the same name take the last one            
      sorted_members  = FasterCSV.read("#{RAILS_ROOT}/data/#{project.name}_sorted_members.csv")
      rankings =  Array.new(1000,0)      
      i = -1 # skip header
      sorted_members.each do |member|
        total_members << member[0]
        i += 1
        #Plot the first 1000 # of Listings
        #Save the 1000 first ranks
        #if i < 1000
        #  rankings[i-1] = member[2]          
        #end
      end      
      project_lists.each do |list|              
        begin
          if list.members != nil
            valid_lists += 1
            members = list.members.count            
            if members > max_users
              max_users = members
            end
            if members < min_users
              min_users = members
            end
            average << members
          end
        rescue
          csv << [community, "List #{list.id}, #{project.name}"]
        end        
      end
      lists_count << valid_lists
      puts "Working on #{sub_community}. ID:#{Project.find_all_by_name(project.name+"lists").last.id}. Lists #{lists_count}"
      
      #Gnuplot.open { |gp|
      #  Gnuplot::Plot.new( gp ) { |plot|
      #    plot.terminal "png"
      #    plot.output "#{RAILS_ROOT}/analysis/results/graphs/#{project.name}.png"
      #    plot.title  "Listings for #{project.name}"
      #    plot.ylabel "# of Listings"
      #    plot.xlabel "Place"
      #    plot.data << Gnuplot::DataSet.new([(1..999).to_a, rankings]) { |ds|
      #      ds.with = "lines"
      #      ds.linewidth = 4
      #    }
      #  }
      #}
    end
    total_average = average.sum / average.count.to_f    
    csv  << [community, projects.join(","), lists_count.sum, total_members.uniq.count, total_average, min_users, max_users]  
  end  
end

outfile.close