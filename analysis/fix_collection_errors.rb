require '../config/environment'
require 'faster_csv'

members = FasterCSV.read("#{RAILS_ROOT}/analysis/results/missing_persons_with_missing_feed_entries.csv").flatten
puts members

members.each do |member|
  person = Person.find_by_username(member)
  begin
    puts "enque person #{person.id}"
    Delayed::Job.enqueue(CollectAllFeedEntriesJob.new(person.id))
  rescue
    puts "could not find #{member}"
  end      
end

continue = true
while continue
  found_pending_jobs = 0				
  Delayed::Job.all.each do |job|			
    if job.handler.include? "CollectAllFeedEntriesJob"
            found_pending_jobs += 1
    end
    if job.attempts >= 4
            puts "#{Project.get_remaining_hits}. Deleting job with more than #{job.attempts} attempts."
            job.delete				
    end
  end
  if found_pending_jobs == 0
    continue = false
  end
  puts "Tweet Collection: #{Project.get_remaining_hits}. Waiting for #{found_pending_jobs} Collect Tweet Jobs to finish..."
  sleep(10)		
end

members.each do |member|
  if Person.find_by_username(member) != nil
    person = Person.find_by_username(member) 
    person.feed_entries.each do |feed_entry|
      if feed_entry.retweet_count.to_i > 0 && feed_entry.retweet_ids == [] # Only collect retweets for those that have made retweets but where we dont have them
        #puts "enque person #{feed_entry.id}"      
        Delayed::Job.enqueue(CollectRetweetIdsForEntryJob.new(feed_entry.id))               
      end
    end
  else
    puts "there is no such person #{member}"
  end
end

continue = true
while continue		
  found_pending_jobs = 0				
  Delayed::Job.all.each do |job|			
    if job.handler.include? "CollectRetweetIdsForEntryJob"
            found_pending_jobs += 1
    end
    if job.attempts >= 4
            puts "#{Project.get_remaining_hits}. Deleting job with more than #{job.attempts} attempts."
            job.delete				
    end
  end
  if found_pending_jobs == 0
    continue = false
  end
  puts "Retweet Collection: #{Project.get_remaining_hits}. Waiting for #{found_pending_jobs} Collect ReTweet Jobs to finish..."
  sleep(120)		
end