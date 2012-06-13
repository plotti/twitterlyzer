require '../config/environment'
require 'faster_csv'
results = []

#deprecated. This file was used for the re-import of old lists which came from the first system

Dir.foreach("#{RAILS_ROOT}/data/old_lists") do |item|
  next if item == "graphs" or item == "." or item == ".."
  puts item.to_s
  sorted_members  = FasterCSV.read("#{RAILS_ROOT}/data/old_lists/#{item}")
  rankings =  []
  i = 0
  sorted_members.each do |member|
    i += 1
    #Save the 1000 first ranks
    if i < 1000
      rankings << member[2]
    end
  end
  
  Gnuplot.open { |gp|
      Gnuplot::Plot.new( gp ) { |plot|
        plot.terminal "png"
        plot.output "#{RAILS_ROOT}/data/old_lists/graphs/#{item}.png"
        plot.title  "Listings for #{item}"
        plot.ylabel "# of Listings"
        plot.xlabel "Place"
        plot.data << Gnuplot::DataSet.new( [(1..999).to_a, rankings]) { |ds|
          ds.with = "lines"
          ds.linewidth = 4
        }
      }
    }	
end

