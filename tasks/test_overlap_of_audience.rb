#!/usr/bin/env ruby
a = []
Person.all.each do |p1|
  a []
  Person.all.each do |p2|    
    h[p1.username] << (p2.follower_ids & p1.follower_ids).count.to_f / (p2.follower_ids.count + p1.follower_ids.count).to_f
  end
end

require 'csv'
outfile = File.open("zeitung_stats.csv",'w')
CSV::Writer.generate(outfile) do |csv|
  t = ""
  Person.all.each do |p|
    t += p.username + (",")
  end  
  csv << [t]
  Person.all.each do |p|    
    csv << h[p.username]
  end    
end
outfile.close