require 'rubygems'  
require 'csv'
require 'uri'

csv_file = "reply_twitter_messages.csv"
twitter_names = "csr_community.txt"

tweets = []
members = []

CSV::Reader.parse(File.open(twitter_names, 'rb')) do |row  |
  result = URI.parse(row.to_s).path.reverse.chop.reverse  
  members <<  result
end

i = 0
CSV::Reader.parse(File.open(csv_file, 'rb')) do |row|
  if i > 0 
    id = row[0]
    text = row[1]
    author = row[2]
    url = row[3]
    date = row[4]
    reply = row[5]
    retweet = row[6]  
    tweets <<  {:id => id, :text => text, :author => author, :url => url,
                :date => date, :reply => reply, :retweet => retweet, :member => ""}
  end
  i += 1
end

tweets.each do |tweet|
  members.each do |member|
    if tweet[:text].include?("@" + member)
      tweet[:member] = tweet[:member] + " " + member
    end
  end
end

outfile = File.open(csv_file + "_stats.csv",'w')

CSV::Writer.generate(outfile) do |csv|
  csv << ["ID", "Text", "Author", "URL", "date",
          "reply", "retweet", "retweet of member of community"]
end

CSV::Writer.generate(outfile) do |csv|
  tweets.each do |tweet|
    csv << [tweet[:id], tweet[:text], tweet[:author], tweet[:url],
            tweet[:date], tweet[:reply], tweet[:retweet], tweet[:member]]
  end
end


projects = [2,4,7,9,14]
results = {}
projects.each do |project|  
  result = {}
  Project.find(project).persons.each do |person|
    person.feed_entries.each do |feed|
      feed.retweet_ids.each do |retweet|                
        projects.each do |tmp_project|
          project_persons = Project.find(tmp_project).persons.collect{|p| p.username}
          if project_persons.include?(retweet["person"])
            result[project.name] += 1
          end
        end        
      end
    end
  end
  results[project.name] = result
end
