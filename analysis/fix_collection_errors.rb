require '../config/environment'
require 'faster_csv'

missing_persons = FasterCSV.read("#{RAILS_ROOT}/analysis/data/missing_persons.csv")
members = FasterCSV.read("#{RAILS_ROOT}/analysis/data/missing_feed_entries.csv").flatten
maxfriends = 100000
category = ""

def wait_for_jobs(jobname)
  continue = true
  while continue
    found_pending_jobs = 0				
    Delayed::Job.all.each do |job|			
      if job.handler.include? jobname
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
    puts "Remaining API hits: #{Project.get_remaining_hits}. Waiting for #{found_pending_jobs} #{jobname} jobs to finish..."
    sleep(10)
  end
end

################ Collect missing persons ######################

missing_persons.each do |member|
  project = Project.find_by_name(member[1])
  Delayed::Job.enqueue(CollectPersonJob.new(member[0],project.id,maxfriends,category))
  members << member[0] # Add those persons to the members
end

wait_for_jobs("CollectPersonJob")

################ Collect feeds for persons ######################

members.each do |member|  
  if Person.find_by_username(member) != nil
    person = Person.find_by_username(member)
    Delayed::Job.enqueue(CollectAllFeedEntriesJob.new(person.id))
  else
    puts "There is no such person #{member}"
  end      
end

wait_for_jobs("CollectAllFeedEntriesJob")

################ Collect retweets for persons ######################

members.each do |member|
  if Person.find_by_username(member) != nil
    person = Person.find_by_username(member) 
    person.feed_entries.each do |feed_entry|
      if feed_entry.retweet_count.to_i > 0 && feed_entry.retweet_ids == [] # Only collect retweets for those that have made retweets but where we dont have them
        Delayed::Job.enqueue(CollectRetweetIdsForEntryJob.new(feed_entry.id))               
      end
    end
  else
    puts "There is no such person #{member}"
  end
end

wait_for_jobs("CollectRetweetIdsForEntryJob")