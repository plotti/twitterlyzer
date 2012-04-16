#!/usr/bin/env ruby
require 'config/environment'
@@log = Logger.new("log/diffusion.log")

task :collect_tweets do
  puts "COLLECTING TWEETS"
  @project = Project.find(ENV["project_id"].to_i)
  @project.persons.each do |person|
    if person.feed_entries.count < person.statuses_count # Only collect for those which have not been collected yet,
      if person.feed_entries.count != 3200  # or collected a maximum of possible tweets
        Delayed::Job.enqueue(CollectAllFeedEntriesJob.new(person.id))
      end
    end    
  end
  Rake::Task['collect_tweets'].reenable  
end

task :collect_retweets do
  @@log.info("Started Tweet collection at #{Time.now} for project_id: #{ENV["project_id"]}")
  puts "COLLECTING RETWEETS"
  @project = Project.find(ENV["project_id"].to_i)
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
  
  @project.persons.each do |person|
    person.feed_entries.each do |feed_entry|
      if feed_entry.retweet_count.to_i > 0 && feed_entry.retweet_ids == [] # Only collect retweets for those that have made retweets but where we dont have them
        Delayed::Job.enqueue(CollectRetweetIdsForEntryJob.new(feed_entry.id))         
      end
    end
  end
  @@log.info("Finished collection of #{@project.feed_entries(1000000).count} tweets at #{Time.now} for project_id: #{ENV["project_id"]}")
  Rake::Task['collect_retweets'].reenable  
end

task :report_success do
  puts "Waiting for SUCCESS"
  @@log.info("Started Re-Tweet collection at #{Time.now} for project_id: #{ENV["project_id"]}")
  @project = Project.find(ENV["project_id"].to_i)
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
  @@log.info("Finished collection of Re-tweets at #{Time.now} for project_id: #{ENV["project_id"]}")
end

task :collect_diffusion => [:collect_tweets, :collect_retweets, :report_success] do
    jobs = Delayed::Job.count
    puts "Finished all necessary tasks. #{jobs} remaining jobs in queue."
    Rake::Task['collect_diffusion'].reenable
end

task :collect_diffusions do
  #already_collected_diffusions = [4, 6, 9, 13, 17, 19, 21, 25, 27, 31, 33, 39, 44, 46, 48, 56, 62, 70, 72, 82, 86, 94, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 123, 137, 141, 143, 145, 149, 153, 155, 157, 158, 159, 160, 161, 162, 163, 164]  
  @@communities = [165, 166, 167, 170, 171, 172, 174, 175, 176, 177, 178, 179, 180, 181, 187, 189, 207, 209, 211, 213, 217, 219, 221, 233, 245, 247, 251, 253, 255, 257, 259, 261, 263, 265, 271, 275, 279, 281, 285, 291, 293, 297, 303, 305, 307, 311, 315, 317, 319, 323, 325, 327, 329, 333, 337, 339, 341, 351, 353, 355, 357, 359, 361, 365, 367, 369, 371, 373, 379, 385, 387, 389, 391, 395, 397, 399, 401, 403, 405, 407, 411, 413, 415, 417, 419, 421, 423, 425, 427, 431, 433, 435, 437, 439, 441, 443, 445, 447, 453, 455, 457, 461, 463, 465, 467, 469, 471, 473, 491, 497, 499, 505, 511, 517, 519, 523, 525, 529, 531, 533, 535, 537, 539, 541, 543, 545, 551, 553, 555, 557, 559, 561, 563, 565, 567, 569, 571, 573, 575, 577, 579, 581]
  @@communities.each do |community|
    ENV["project_id"] = community.to_s
    Rake::Task['collect_diffusion'].invoke
  end
end
