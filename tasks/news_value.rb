# This file is an experiment to see how many retweets certain tweets containing a certain word get

require '../config/environment'
#words = %w{useful helpful valuable informative practical convenient handy usable absorbing arresting consuming engaging engrossing enthralling fascinating gripping immersing intriguing involving riveting}
#words = %w{funny entertaining hilarious amusing humorous}
#words = %w{success achievement acquirement attainment}
emotion_words = %w{love hate wow fuck lol laugh cry scream damn shit nice like lovely good great}
news_words = %w{new today release launch announce hot current latest recent news just}

IDS = 6
url_regexp = /http:\/\/\w/
for id in 2..IDS  
  project = Project.find(id)
  total_feeds = 0
  total_retweets = 0
  interesting_retweets = 0
  interesting_tweets = []
  project.persons.each do |p|
    total_feeds += p.feed_entries.count
    follower_match = false
    if p.followers_count.to_i > 2500
      follower_match = true
    end
    p.feed_entries.each do |f|    
      total_retweets += f.retweet_ids.count
      match = false
      news_match, url_match, emo_match = false      
      url = f.text.split.grep(url_regexp)
      if url != []
        url_match = true
      end
      emotion_words.each do |word|
        if f.text.downcase.include? word
          emo_match = true
          break
        end
      end
      news_words.each do |word|
        if f.text.downcase.include? word
          news_match = true
          break
        end
      end
      if news_match && emo_match && url_match && follower_match
        match = true
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
 
  #Remove Stopwords
  interesting_tweets.each do |tweet|
    STOP_WORDS.each do |stopword|
      tweet.text.gsub!(/(\s|^)#{stopword}\s/i, " ")
    end  
  end  
  
  most_used_words = {}
  interesting_tweets.each do |tweet|
    tweet.text.split.each do |word|
      if most_used_words[word] == nil
          most_used_words[word] = 1
      else
        most_used_words[word] += 1
      end
    end
  end
  r = most_used_words.sort{|a,b| a[1] <=> b[1]}.reverse
  result << "Most used words: "
  result << r[0..20].join(" ")
  result << "\n ################################################################ \n"

  puts result
end
