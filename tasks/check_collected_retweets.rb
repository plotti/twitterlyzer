#check retweets
require '../config/environment'

if ARGV[0] == nil
	puts "Please supply the project id for the check"
	break
end

pr = Project.find(ARGV[0])

pr.persons.each do |p|
  r = 0
  p.feed_entries.each do |f|
    r += f.retweet_ids.count
  end
  if r == 0
    puts "Have to collect retweets for person #{p.username}"
    #Delayed::Job.enqueue(CollectPersonRetweetsJob.new(p.id))
  else
    puts "#{r} Retweets for person #{p.username} have been collected"
  end
end
