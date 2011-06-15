require '../config/environment'
#words = %w{useful helpful valuable informative practical convenient handy usable absorbing arresting consuming engaging engrossing enthralling fascinating gripping immersing intriguing involving riveting}
#words = %w{funny entertaining hilarious amusing humorous}
#words = %{success achievement acquirement attainment}
words = %{love hate}
project = Project.find(2)
total_feeds = 0
total_retweets = 0
interesting_retweets = 0
interesting_tweets = []
project.persons.each do |p|
  total_feeds += p.feed_entries.count
  p.feed_entries.each do |f|    
    total_retweets += f.retweet_ids.count
    match = false
    words.each do |word|
      if f.text.include? word
        match = true
        break
      end
    end
    if match
      interesting_retweets += f.retweet_ids.count
      interesting_tweets << f
    end
  end
end
total_avg = total_retweets.to_f / total_feeds.to_f
interesting_avg = interesting_retweets.to_f / interesting_tweets.count.to_f
result = ""
result << "Community: #{project.name} \n "
result << "Total Tweets:#{total_feeds} generated #{total_retweets} retweets \n"
result << "Interesting Tweets: #{interesting_tweets.count} (#{interesting_tweets.count.to_f / total_feeds.to_f})% of Total Tweets generated #{interesting_retweets} Retweets \n"
result << "Baseline Percentage of Tweets per Retweets: #{total_avg} \n"
result << "Interesting Tweets Percentage of Tweets per Retweets:#{interesting_avg} \n"
puts result
