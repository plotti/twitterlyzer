require '../config/environment'
require 'faster_csv'

thresholds = [1000,100,10]
positions =  [50,100,200,1000]

outfile = File.open("#{RAILS_ROOT}/analysis/results/lists_stats.csv",'w')

CSV::Writer.generate(outfile) do |csv|
  csv << ["community name", "# lists", "total members on lists", "# members with threshold 1000", "# members with threshold 100", "# members with threshold 10", "#listings 50th member", "# listings for 100th member", "# listings for 200th member", "# listings for 1000th member"]
end

CSV::Writer.generate(outfile) do |csv|
  @@communities.each do |community|
    
    project = Project.find(community)
    begin
      lists = Project.find_by_name(project.name+"lists").lists
      lists_count = lists.count
    rescue
      lists = "NaN"
      lists_count = "NaN"
    end
    
    sorted_members  = FasterCSV.read("#{RAILS_ROOT}/data/#{project.name}_sorted_members.csv")
    
    
    #TODO: Compute an overlap of members (How many members of this list can be found on other lists?)
    
    
    #Ininitiate Sizes & Listings & Rankings
    rankings =  []
    sizes  = {}
    listings = {}
    thresholds.each do |threshold|
      sizes[threshold] = 0
    end
        
    #Count
    i = 0
    sorted_members.each do |member|
      i += 1
      
      #Note # of listings 
      positions.each do |position|
        if i == position
          listings[position] = member[2]
        end         
      end
      
      #Calculate community size based on threshold
      thresholds.each do |threshold|
        if member[2].to_i > threshold
          sizes[threshold] += 1
        end      
      end
      
      #Save the 1000 first ranks
      if i < 1000
        rankings << member[2]
      end
      
    end
          
    #Plot the first 1000 # of Listings
    Gnuplot.open { |gp|
      Gnuplot::Plot.new( gp ) { |plot|
        plot.terminal "png"
        plot.output "#{RAILS_ROOT}/analysis/results/graphs/#{project.name}.png"
        plot.title  "Listings for #{project.name}"
        plot.ylabel "# of Listings"
        plot.xlabel "Place"
        plot.data << Gnuplot::DataSet.new( [(1..999).to_a, rankings]) { |ds|
          ds.with = "lines"
          ds.linewidth = 4
        }
      }
    }
    
    csv  <<[ project.name, lists_count, sorted_members.size, sizes[1000], sizes[100], sizes[10], listings[50], listings[100], listings[200], listings[1000]]  
  end
end

outfile.close