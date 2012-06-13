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


####Get Tunkrank #########
require 'csv'
outfile = File.open("zeitung_tunkrank.csv","w")
CSV::Writer.generate(outfile) do |csv|
csv << ["username", "raw_score", "ranking", "date"]
  Person.all.each do |p|
    puts p.username
    r = TunkRank.score(p.username)
    csv << [p.username, r["twitter_user"]["raw_tunkrank_score"], r["twitter_user"]["ranking"], r["twitter_user"]["tunkrank_computed_at"]]
  end
end
outfile.close


### Get the Retweeters with the most followers
### aka the influentials

max = []
Person.all.each do |person|
  person.feed_entries.each do |entry|
    entry.retweet_ids.each do |retweet|
      max << {:person => retweet[:person], :following => person.username, :followers_count => retweet[:followers_count], :tweet => entry.text}
    end
  end
end
r = []
101.times do
  r << max.max{|a,b| a[:followers_count] <=> b[:followers_count]}
  max.delete_at(max.index(max.max{|a,b| a[:followers_count] <=> b[:followers_count]}))
end

require 'csv'
outfile = File.open("top_retweeters.csv","w")
CSV::Writer.generate(outfile) do |csv|
csv << ["following", "tweet", "followers", "person"]
  r.each do |row|
    csv << [row[:following], row[:tweet], row[:followers_count], row[:person]]
  end
end
outfile.close