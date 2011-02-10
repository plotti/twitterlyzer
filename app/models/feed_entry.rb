class FeedEntry < ActiveRecord::Base
  require 'open-uri'
  require 'simple-rss'
  require 'json'
  require 'typhoeus'
  require 'gnuplot'
  include Typhoeus
  serialize :retweet_ids  
  
  #Constants
  ENTRIES_PER_PAGE = 200
  BITLY_LOGIN = "plotti"
  BITLY_API_KEY = "R_fb1f65003bba56b566ed65be4a773741"
  
  
  CONSUMER_KEY = "lPeEtUCou8uFFOBt94h3Q"
  CONSUMER_SECRET = "iBFQqoV9a5qKCiAfitEXFzvkD7jcpSFupG8FBGWE"
  ACCESS_TOKEN = "15533871-abkroGVmE7m1oJGzZ38L29c7o7vDyGGSevx6X25kA"
  ACCESS_TOKEN_SECRET = "pAoyFeGQlHr53BiRSxpTUpVtQW0B0zMRKBHC3hm3s"
  
  
  def remove_format(text)
    gsub(/\r\n?/, "").
    gsub(/\n\n+/, "").
    gsub(/([^\n]\n)(?=[^\n])/, "")
  end
  
  #define_remote_method :user_timeline, :path => '/statuses/user_timeline.rss',
  #                     :base_uri => "http://twitter.com",
  #                     :on_success => lambda {|response| SimpleRSS.parse(response.body)},
  #                     :on_failure => lambda {|response| puts "error code: #{response.code}"},
  #                     :headers => {"Authorization" => "Basic #{Base64.b64encode(TWITTER_USERNAME + ":" + TWITTER_PASSWORD)}"}
  #
  #define_remote_method  :get_status, :path => '/statuses/show.json',
  #                        :base_uri => "http://twitter.com",
  #                        :on_success => lambda {|response| JSON.parse(response.body)},
  #                        :on_failure => lambda {|response| puts "error code: #{response.code}"},
  #                        :headers => {"Authorization" => "Basic #{Base64.b64encode(TWITTER_USERNAME + ":" + TWITTER_PASSWORD)}"}
  #
  
  define_remote_method :expand_url, :path =>'http://api.bit.ly/expand',
                       :params => {:version => "2.0.1", :login => BITLY_LOGIN, :apiKey => BITLY_API_KEY},
                       :on_success => lambda{|response| JSON.parse(response.body)},
                       :on_failure => lambda{|response| puts "error code: #{response.code}"}
                       
  #Associations
  belongs_to :person
  
  #Sphinx
  is_indexed :fields => ['text', 'author', 'url']
    
  #Collects all possible rss entries from one person on twitter 
  def self.collect_all_entries(person)
    
    puts "Collecting Tweets for Person #{person.username}"
    feeds = []    
    page = 1
    more_tweets_found = true
    
    #Gather Feeds from Twitter
    while more_tweets_found
      begin
        puts "On page #{page}"
        r = @@twitter.user_timeline("plotti", {:count => ENTRIES_PER_PAGE, :page => page})        
        #r = @@client.statuses.user_timeline? :screen_name => person.username, :page => page, :count => ENTRIES_PER_PAGE
        if r == []
          more_tweets_found = false
        end
        feeds << r
      rescue Grackle::TwitterError => e
        puts e.class
        SystemMessage.add_message("error", "Grackle Error", e)
        retry
      rescue Exception => e
        puts e.class
        SystemMessage.add_message("error", "Collect all entries", "User " + person.username + " not found.#{e}")
      end
      page += 1
    end
    
    #Add to Database
    if feeds != nil
      feeds.each do |f|
        FeedEntry.add_entries(f, person)
      end      
      logger.info "Collect_all_entries -- Collected Tweets of " + person.username
      
      return feeds
    end
  end
  
  #Marks for the collected retweets if those are isolates in the network or not
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
    
  def self.update_person_entries(person)
    page = 1  
    newer_entries_exist = true
    entries_to_add = []
    entries_pp = 50
    switch = true          
    latest_published_db_entry = person.feed_entries.maximum("published_at")
    if latest_published_db_entry == nil
      latest_published_db_entry = Time.at(0)
    end          
    while newer_entries_exist
      begin
        entries = @@client.statuses.user_timeline :screen_name => person.username, :page => page, :count => entries_pp
        #entries = FeedEntry.user_timeline(:params => {:id => person.twitter_id, :page => page, :count => entries_pp}).entries
      rescue
        puts "User not found: " + person.username
        entries = []
      end            
      if entries.count == 0
        newer_entries_exist = false
      end
      entries.each do |entry|
        if entry.pubDate > latest_published_db_entry
          entries_to_add << entry
        else
          newer_entries_exist = false
        end
      end
      # 50,50,50,50,200,200,....
      if page == 4 && switch
        entries_pp = 200
        page = 1
        switch = false
      end
      page = page + 1
    end    
    FeedEntry.add_entries(entries_to_add, person)
    person.update_attributes(:statuses_count => person.statuses_count + entries_to_add.count)
    logger.info(entries_to_add.count.to_s + " Entries updated for user: " + person.username)    
  end
  
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
  
  def self.create_retweet_network(feed_id,project_id)
    feed = FeedEntry.find(feed_id)
    #tweets = []
    persons = []
    #add initial tweet    
    #tmp = @@client.statuses.show? :id => feed.guid
    #tweets << tmp
    persons << feed.person
    tweets = feed.retweet_ids    
    #feed.retweet_ids.collect{|r| r[:id]}.uniq.each do |id|
    tweets.each do |tweet|
      begin
        #puts "Collecting Person for tweet: #{id}"
        #tweet = @@client.statuses.show? :id => id            
        person = Person.collect_person(tweet[:person], project_id, 100000)
        #FeedEntry.add_entry(tweet, person)
        persons << person        
        #tweets << tweet
      rescue
        puts "Could not get tweet #{id}"
      end
      
    end
    return {:tweets => tweets, :persons => persons}
  end
  
  def chunk n
    each_slice(n).reduce([]) {|x,y| x += [y] }
  end

  def self.collect_retweet_ids(entry)    
    i = 0
    i += 1
    puts "(#{i} COLLECTING RETWEETS FOR ENTRY #{entry.guid}"
    entry.retweet_ids = []
    entry.save!
    begin        
      @@client.statuses.retweets?(:id => entry.guid, :count => 100).each do |retweet|
        #Collect all Persons on initial try takes a long time!        
        Person.collect_person(retweet.user.screen_name, entry.person.project.first.id, 100000)
        entry.retweet_ids << {:id => retweet.id, :person => retweet.user.screen_name, :followers_count => retweet.user.followers_count, :published_at => retweet.created_at}
      end      
      entry.save!
    rescue
      puts "Couldnt't get retweets for id:#{entry.guid}"
    end    
  end
  
  def self.collect_entry_and_person(twitter_id, project_id)
    entry = @@client.statuses.show? :id => twitter_id
    person = Person.collect_person(entry.user.screen_name, project_id, 10000, friends = true, followers = false)            
    FeedEntry.add_entry(entry, person)
  end
  
  def self.collect_retweet_ids_for_entry(entry)
    puts "(COLLECTING RETWEETS FOR ENTRY #{entry.guid}"
    @@client.statuses.retweets?(:id => entry.guid).each do |retweet|
      entry.retweet_ids << {:id => retweet.id, :person => retweet.user.username}
    end      
    entry.save!
  end
  
  def get_at_tags
    self.text.gsub(/@(\w+)/).to_a
  end
  
  def get_hash_tags
    self.text.gsub(/#(([a-z_\-]+[0-9_\-]*[a-z0-9_\-]+)|([0-9_\-]+[a-z_\-]+[a-z0-9_\-]+))/).to_a
    #self.text.gsub(/#(\w+)/).to_a
  end
  
  def get_urls
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
  
  def self.add_entry(entry,person)
    unless exists? :guid => entry.guid
        create!(
          :text         => entry.text,
          :author       => person.name,
          :url          => "http://twitter.com/" + entry.user.screen_name.to_s + "/status/" + entry.id.to_s,
          :published_at => entry.created_at,
          :guid         => entry.id,
          :person_id    => person.id,
          :retweet_ids  => [],
          :reply_to     => entry.in_reply_to_status_id.to_s,
          :geo          => entry.geo
        )
    end
  end
  
end