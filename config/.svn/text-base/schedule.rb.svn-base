# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :cron_log, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
set :path, '/home/thomas/socialyzer' 

every 30.minutes do
  #runner "SystemMessage.add_message('info', 'Test', 'Cronjob successfully fired.')", :environment => :production
  runner "Person.update_all_persons"
  runner "FeedEntry.update_rss"
  runner "Project.write_stats_to_disk"
  runner "Project.write_net_to_disk"
end
