require 'config/environment'
p = Project.last
file = File.open("out.txt","w+")
names = p.persons.collect{|t| t.username}
r = []
file.puts "Name; Selfmentions; Othermentions; Total Tweets"
p.persons.each do |person|
        puts "working on #{person.username}"
        selfmentions = 0
        othermentions = 0
        person.feed_entries.each do |feed|
                if feed.text.include?("@") && !feed.text.include?("RT")
                   if feed.retweet_ids == [] # not a retweet
                        name_found = false
                        names.each do |name|
                                if feed.text.include? name
                                        selfmentions += 1
                                        name_found = true
                                        break
                                end
                        end
                        if !name_found
                                othermentions += 1
                        end
                   end
                end
        end
        file.puts "#{person.username};#{selfmentions};#{othermentions};#{person.feed_entries.count}"
end

