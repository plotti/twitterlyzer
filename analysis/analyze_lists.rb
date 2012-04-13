require '../config/environment'
require 'faster_csv'

thresholds = [1000,100,10]
positions =  [1,50,100,200,1000]

outfile = File.open("#{RAILS_ROOT}/analysis/results/lists_stats.csv",'w')

#@@communities = ["geography","columnist","linguistics","literacy","alternativehealth","dental","veteran","smartphone","seniors","html","diversity","sculpture","poverty","archaeology","database","neuroscience","army","filmfestival","sociology","chemistry","housing","justice","drums","ecology","mathematics","anthropology","collectibles","magician","drama","hacking","biology","marriage","nursing","mobilephones","activism","climbing","ipad","pharma","reporter","storage","physics","pregnancy","democrat","classicalmusic","banking","hollywood","homeschool","dining","genealogy","agriculture","piano","buddhism","realitytv","mentalhealth","toys","climatechange","documentary","islam","employment","boating","hunting","cancer","fantasy","gambling","theater","liberal","multimedia","jewish","romance","teaching","jokes","weather","engineering","legal","baking","newspaper","attorney","rugby","aviation","wrestling","composer","electronicmusic","greenliving","meditation","highered","peace","horror","philanthropy","racing","chef","screenwriter","humanrights","insurance","jazz","career","military","school","drinking","energy","father","painting","exercise","flash","construction","university","tvshows","motorcycle","vegetarian","skiing","recipes","opensource","animation","skateboarding","lesbian","medicine","management","director","nature","swimming","economics","magazine","children","fishing","weightloss","psychology","literature","hockey","philosophy","nutrition","parenting","blogs","iphone","cooking","beauty","wine","singer","developer","publicrelations","actor","writing","author","fitness","funny","shopping","gaming","fashion"]

@@communities = [477]
CSV::Writer.generate(outfile) do |csv|
  csv << ["community name", "# lists", "total members on lists", "# members with threshold 1000", "# members with threshold 100", "# members with threshold 10", "#listings 1st member", "# listings for 50th member", "# listings for 100th member", "# listings for 200th member", "# listings for 1000th member"]
end

CSV::Writer.generate(outfile) do |csv|
  @@communities.each do |community|
    
    puts "Working on #{community}"
    project = Project.find(community)
    begin
      lists = Project.find_all_by_name(project.name+"lists").last.lists # if we happen to have two take the last one
      lists_count = lists.count
    rescue
      lists = "NaN"
      lists_count = "NaN"
    end
    
    sorted_members  = FasterCSV.read("#{RAILS_ROOT}/data/#{project.name}_sorted_members.csv")
    
    
    #TODO: Compute an overlap of members (How many members of this list can be found on other lists?)
    
    
    #Ininitiate Sizes & Listings & Rankings
    rankings =  Array.new(1000,0)
    unique_uris = 
    sizes  = {}
    listings = {}
    thresholds.each do |threshold|
      sizes[threshold] = 0
    end
        
    #Count
    i = -1 # skip header
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
        rankings[i-1] = member[2]          
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
    
    csv  <<[ project.name, lists_count, sorted_members.size, sizes[1000], sizes[100], sizes[10], listings[1], listings[50], listings[100], listings[200], listings[1000]]  
  end
end

outfile.close