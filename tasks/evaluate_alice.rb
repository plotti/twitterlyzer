#!/usr/bin/env ruby
require 'gnuplot'

keyword = "maravilha"
result = FeedEntry.find(:all, :conditions =>  ["text LIKE ? AND published_at > ?", "%alice%#{keyword}%", "2010-02-01"])

r = Hash.new
start = result.min{|a,b| a.published_at <=> b.published_at}.published_at
result.each do |t|
  day = ((t.published_at-start)/(3600*24)).round
  r[day] == nil ? r[day] = 1 : r[day] += 1
end

x = []
y = []
r.sort.each do |e|
  x <<  e[0]
  y <<  e[1]
end

Gnuplot.open do |gp|
 Gnuplot::Plot.new(gp) do |plot|
  plot.terminal "png"
  plot.output "alice_#{keyword}_days_feb.png"
  plot.data = [
    Gnuplot::DataSet.new([x,y]){ |ds|
       ds.with = "linespoints"
       ds.title = "Alice in #{keyword}"
    }
  ]
 end
end


#get results by author
results_by_author = FeedEntry.count(:group => "person_id", :conditions =>  ["text LIKE ? AND published_at > ?", "%alice%#{keyword}%", "2010-02-01"])

results_by_author.each do |k,v|
  puts Person.find(k).username + " posts " + v.to_s
end
