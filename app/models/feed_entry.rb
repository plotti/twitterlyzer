class FeedEntry < ActiveRecord::Base
  require 'open-uri'
  require 'simple-rss'
  require 'json'
  require 'typhoeus'
  require 'gnuplot'
  include Typhoeus
  serialize :retweet_ids  
  
  #Associations
  belongs_to :person
  
  #Constants
  ENTRIES_PER_PAGE = 200      
   
  define_remote_method :expand_url, :path =>'http://api.bit.ly/expand',
                       :params => {:version => "2.0.1", :login => BITLY_LOGIN, :apiKey => BITLY_API_KEY},
                       :on_success => lambda{|response| JSON.parse(response.body)},
                       :on_failure => lambda{|response| puts "error code: #{response.code}"}
                       
  
  #Sphinx
  #is_indexed :fields => ['text', 'author', 'url']
    
  #Collects all possible rss entries from one person on twitter
  # Tested
  def self.collect_all_entries(person)
    
    while Project.get_remaining_hits == "timeout"
      sleep(60) 
    end
    
    puts "Collecting Tweets for Person #{person.username}"
    feeds = []    
    page = 1
    more_tweets_found = true    
    
    #Gather Feeds from Twitter
    while more_tweets_found
      begin
        puts "On page #{page}"
        #if @@twitter.rate_limit_status.remaining_hits > 20
          r = @@twitter.user_timeline(person.username, {:count => ENTRIES_PER_PAGE, :page => page, :include_rts => :true})         
        #else
        #  sleep(120)
        #end          
        if r == []
          more_tweets_found = false
        else
          #Add to Database
          feeds << r          
          FeedEntry.add_entries(r, person)
        end
      rescue Twitter::BadGateway => e        
        puts e.class
        retry
      rescue Twitter::ServiceUnavailable => e
        puts e.class
        retry
      rescue Twitter::Unauthorized => e
        puts e.class
        #SystemMessage.add_message("error", "Collect all entries", "Unauthorized error " + person.username + " not found.#{e}")
      rescue Twitter::NotFound => e
        #SystemMessage.add_message("error", "Collect all entries", "User " + person.username + " not found.#{e}")
      rescue Exception => e
        puts e.class
        #SystemMessage.add_message("error", "Collect all entries", "General error for User " + person.username + " not found.#{e}")
      end
      page += 1
    end    
    
    if feeds != nil
      logger.info "Collect_all_entries -- Collected #{page} Pages of Tweets of " + person.username      
    end
    return feeds
  end
  
  #Marks for the collected retweets if those are isolates in the network or not
  #TODO TEST
  #TODO Describe
  def self.mark_isolates(retweets,o_tweet)
    tweets = retweets
    #Mark Isolate Tweets
    persons = []
    persons << o_tweet.person
    tweets.each do |tweet|
      if (person = Person.find_by_username(tweet[:person])) != nil      
        persons << person      
      end      
    end
    puts persons.size
    retweet_net = Project.find_all_persons_connections(persons)    
    tweets.each do |tweet|
      begin
        person = Person.find_by_username(tweet[:person])        
        isolate_status = "isolate"
        retweet_net.each do |row|          
          if row[0] == person.twitter_id || row[1] == person.twitter_id
            isolate_status = "second_ego"
            break
          end
        end
        if person.friends_ids.include?(o_tweet.person.twitter_id)	
          isolate_status = "first_ego"
        end
        tweet[:isolate_status] = isolate_status
      rescue
      end      
    end
    return tweets
  end
  
  #TODO Test
  #TODO Describe
  def generate_tweet_plot
    tweets = FeedEntry.mark_isolates(self.retweet_ids,self)
  
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.terminal "svg"
        plot.output id.to_s + ".svg"
        plot.data = []
        r = Hash.new
        s = Hash.new
        i = Hash.new
        origin_date = DateTime.parse(FeedEntry.find(id).published_at.to_s)
        tweets.each do |tweet|          
          hour_diff = (DateTime.parse(tweet[:published_at])-origin_date).hours.to_i
          if (person = Person.find_by_username(tweet[:person])) != nil
            if person.friends_ids.include?(self.person.twitter_id)	
              r[hour_diff] == nil ? r[hour_diff] = tweet[:followers_count] : r[hour_diff] += tweet[:followers_count]  
            elsif tweet[:isolate_status] == "isolate"
              i[hour_diff] == nil ? i[hour_diff] = tweet[:followers_count] : r[hour_diff] += tweet[:followers_count]  
            else
              s[hour_diff] == nil ? s[hour_diff] = tweet[:followers_count] : s[hour_diff] += tweet[:followers_count]  
            end
          end
        end
        x = []
        y = []
        x1 = []
        y1 = []
        x2 = []
        y2 = []
        total = 0
        values = {}
        i.sort.each do |e|
          if e[0] < 2*(x1.inject(0.0){|sum, el| sum + el }/x2.size) || x2.size < 5
              total += e[1]
              x2 << e[0]
              y2 << total
          end
        end
        s.sort.each do |e|            
            if e[0] < 2*(x1.inject(0.0){|sum, el| sum + el }/x1.size) || x1.size < 5
              total += e[1]
              x1 << e[0]
              y1 << total
            end
        end
        r.sort.each do |e|            
            if e[0] < 2*(x.inject(0.0){|sum, el| sum + el }/x.size) || x.size < 5
              total += e[1]        
              x << e[0]
              y << total
            end
        end
        values[:ego_retweets] = [x,y]
        values[:ego2_retweets] = [x1,y1]
        values[:isolate_retweets] = [x2,y2]
        values.each do |k,v|
          plot.data << Gnuplot::DataSet.new([v[0],v[1]]){|ds|
            ds.with = "linespoints"
            ds.title = k
            }
        end
      end
    end    
  end
  
  #TODO: Is this method deprecated? 
  def self.generate_plot(tweets, title)
   Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.terminal "svg"
        plot.output title + ".svg"
        plot.data = []
        r = Hash.new
        origin_date = tweets.collect{|t| DateTime.parse(t.created_at)}.min
        tweets.each do |tweet|          
          hour_diff = (DateTime.parse(tweet.created_at)-origin_date).hours.to_i
          puts DateTime.parse(tweet.created_at).strftime("%d.%m %H:%M") + hour_diff.to_s
          r[hour_diff] == nil ? r[hour_diff] = tweet.user.followers_count : r[hour_diff] += tweet.user.followers_count
        end
        x = []
        y = []
        total = 0
        #outfile = File.open("#{title}.csv", 'wb')
        #CSV::Writer.generate(outfile) do |csv|
        #  csv << ["Time", "Readers Reached"]
        #  r.sort.each do |e|            
        #    total += e[1]
        #    csv << [e[0],total]
        #    x << e[0]
        #    y << total
        #  end
        #end
        #outfile.close
        values = {}
        values[:readers_reached] = [x,y]        
        values.each do |k,v|
          plot.data << Gnuplot::DataSet.new([v[0],v[1]]){|ds|
            ds.with = "linespoints"
            ds.title = k
            }
        end
      end
   end
  end
  
  # For a given tweet, it goes through its retweets and returns all the retweets that are
  # in the ego-network of the collected person.
  def ego_net_retweets
    retweets = []
    self.retweet_ids.each do |retweet|    
      begin
      if Person.find_by_username(retweet[:person]).friends_ids.include?(self.person.twitter_id)      
        retweets << retweet
      end
      rescue
      end      
    end
    return retweets
  end
  
  # Creates a network of persons that retweeted a given tweet.
  def self.create_retweet_network(feed_id,project_id)
    feed = FeedEntry.find(feed_id)
    persons = []
    persons << feed.person
    tweets = feed.retweet_ids    
    tweets.each do |tweet|
      begin
        person = Person.collect_person(tweet[:person], project_id, 100000)
        persons << person        
      rescue
        puts "Could not get person for tweet #{id}"
      end
      
    end
    return {:tweets => tweets, :persons => persons}
  end
  
  def chunk n
    each_slice(n).reduce([]) {|x,y| x += [y] }
  end


  # Collects the persons and retweets of a tweet
  def self.collect_retweet_ids_for_entry_with_persons(entry)
    entry = FeedEntry.collect_retweet_ids_for_entry(entry)
    entry.retweet_ids.each do |retweet|      
      Person.collect_person(retweet[:person], entry.person.project.first.id, 100000)
    end
  end
 
  #Collects the retweets of a tweet
  #TESTED
  def self.collect_retweet_ids_for_entry(entry)
    if entry.retweet_count.to_i > 0       
      entry.retweet_ids = []
      entry.save!
      begin
        if @@twitter.rate_limit_status.remaining_hits > 20
          @@twitter.retweeters_of(entry.guid, {:count => 100}).each do |retweet|
            entry.retweet_ids << {:id => retweet.id, :person => retweet.screen_name, :followers_count => retweet.followers_count, :published_at => retweet.created_at}
          end    
          entry.save!
        else
          puts "Waiting for 2 minutes since there are no API calls left."
          sleep(120)
        end
      rescue
        puts "Couldnt't get retweets for id:#{entry.guid}"
      end
    end    
    return entry
  end
  
  # For a erson for all its tweets collects the retweets  
  def self.collect_retweet_ids_for_person(person)
    while Project.get_remaining_hits == "timeout"
      sleep(60) 
    end
    person.feed_entries.each do |entry|      
      FeedEntry.collect_retweet_ids_for_entry(entry)
    end
  end
  
  def self.collect_entry_and_person(twitter_id, project_id)
    entry = @@client.statuses.show? :id => twitter_id
    person = Person.collect_person(entry.user.screen_name, project_id, 10000, friends = true, followers = false)            
    FeedEntry.add_entry(entry, person)
  end
  
  def remove_format(text)
    gsub(/\r\n?/, "").
    gsub(/\n\n+/, "").
    gsub(/([^\n]\n)(?=[^\n])/, "")
  end
  
  #returns all the @ tags in the tweet
  def get_at_tags
    self.text.gsub(/@(\w+)/).to_a
  end
  
  #returns all the hash tags in the tweet
  def get_hash_tags
    self.text.gsub(/#(([a-z_\-]+[0-9_\-]*[a-z0-9_\-]+)|([0-9_\-]+[a-z_\-]+[a-z0-9_\-]+))/).to_a
    #self.text.gsub(/#(\w+)/).to_a
  end
  
  def get_urls
    self.text.gsub!("”", "")
    a = self.text.gsub(/((https?:\/\/|www\.)([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/).to_a   
  end
  
  def get_expanded_urls
    results = []
    if self.get_urls != []    
      self.get_urls.each do |url|        
        begin
          url_to_check = URI.parse(url).host 
        rescue
          url_to_check = ""
        end
        if url_to_check == "bit.ly"
          begin
            tmp_res = FeedEntry.expand_url(:params => {:shortUrl => url})
          rescue
          end
          if tmp_res != nil
            temp = tmp_res["results"]
            errorcode = tmp_res["statusCode"]          
            if errorcode != "ERROR"
              if temp != nil                 
                key = temp.keys.first
                results << temp[key]["longUrl"]
              end
            end
          end        
      else
        results << url
        end
      end      
    end
    return results
  end
  
  #Update persons
  def self.update_rss    
    Project.all.each do |project|      
      if project.monitor_feeds == true
        project.persons.each do |person|          
          Delayed::Job.enqueue(UpdateFeedEntriesJob.new(person.id))
        end
        SystemMessage.add_message("info", "Update RSS ",  "Scheduled tweets update for Project " + project.name + ".")
      end      
    end
  end
  
  #Returns number of remaining Twitter API Hits
  def self.get_remaining_api_hits()
    result = {}
    begin
      Timeout::timeout(5){
        result = @@client.account.rate_limit_status?.remaining_hits
      }
    rescue Timeout::Error
      result = "Twitter Timeout"
    end    
    return result
  end
  
  private
  
  #Adds Feed Entries to DB
  def self.add_entries(entries, person)
    entries.each do |entry|
      FeedEntry.add_entry(entry,person)
    end
  end
  
  #Only adds entries if they are not already existing.
  def self.add_entry(entry,person)
    unless exists? :guid => entry.id_str
        create!(
          :text         => entry.text,
          :author       => person.name,
          :url          => "http://twitter.com/" + entry.user.screen_name.to_s + "/status/" + entry.id.to_s,
          :published_at => entry.created_at,
          :guid         => entry.id_str,
          :person_id    => person.id,
          :retweet_ids  => [],
          :reply_to     => entry.in_reply_to_status_id.to_s,
          :geo          => entry.geo,
          :place        => entry.place,
          :in_reply_to_user_id => entry.in_reply_to_user_id,
          :retweeted    => entry.retweeted,
          :retweet_count => entry.retweet_count,
          :contributors  => entry.contributors,
          :favorited     => entry.favorited,
          :truncated     => entry.truncated,
          :coordinates   => entry.coordinates,
          :source        => entry.source
        )
    end
  end
  
end