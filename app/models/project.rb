class Project < ActiveRecord::Base
  #require "graphviz"
  require "csv"
  require 'scrapi'
  #require 'igraph'

  #associations
  has_and_belongs_to_many :persons
  has_many :searches
  has_many :lists
  has_many :system_messages, :as => :messageable

  WEFOLLOW_BASE_URL = "http://wefollow.com/twitter/"
  
  @@wefollow_scraper = Scraper.define do
    array :items
    #div+div>div.person-box
    process "#results>div", :items => Scraper.define {
      #process "div", :name => :text
      process "div.result_row>div.result_details>p>strong>a", :name => :text     
    }    
    result :items
  end
  
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

  def self.graph_net(project_id)  
    project = Project.find(project_id)
    persons = project.persons       
    g = GraphViz::new( "G" )    
    project_net = project.find_all_connections(friend = true, follower = false)
    
    #add nodes and edges
    project_net.each do |entry|
      g.add_node(entry[0])
      g.add_edge(entry[0],entry[1])
      g.output( :output => "png", :use=> "fdp", :file => "#{project.name.gsub!(" ","_")}.png" )
    end
  end  
  
  def self.find_k_cores(project_id, core)
    project = Project.find(project_id)
    persons = project.persons    
    followers = project.followers
    
    g = IGraph.new([],true)
    
    followers.each do |follower|
      follower_id = Person.find_by_username(follower.person).id
      followed_by_id = Person.find_by_username(follower.followed_by_person).id
      edges << follower_id
      edges << followed_by_id
      #g.add_vertex(follower_id)
      #g.add_vertex(followed_by_id)
      #g.add_edge(follower_id, followed_by_id)
    end
    
    return g
  end
  
  #Write project people net to disk
  def self.write_net_to_disk
    content_type = ' text/csv '    
    Project.all.each do |project|      
      if project.monitor_feeds == true
        project_net = project.find_all_connections(friend = true, follower = false)                
        outfile = File.open(RAILS_ROOT + "/log/" + project.name + "_SNA_" + Time.now.strftime("%d_%m_%Y %I:%M").to_s + ".csv", 'w')      
        CSV::Writer.generate(outfile) do |csv|
          csv << ["DL n=" + project.persons.count.to_s ]
          csv << ["format = edgelist1"]
          csv << ["labels embedded:"]
          csv << ["data:"]
          project_net.each do |entry|
            csv << [entry[0], entry[1], "1"]
          end
        end
        outfile.close
        SystemMessage.add_message("info", "Write net to disk", project.name + " net was written to disk.")          
      end
    end
  end
  
  #Write project stats to disk 
  def self.write_stats_to_disk
    content_type = ' text/csv '
    Project.all.each do |project|      
      if project.monitor_feeds == true
        outfile = File.open(RAILS_ROOT + "/log/" + project.name + "_STATS_" + Time.now.strftime("%d_%m_%Y %I:%M").to_s + ".csv", 'w')      
        CSV::Writer.generate(outfile) do |csv|
          csv << ["Person", "Twitter_Username", "Friends", "Followers", "Messages"]
          project.persons.each do |person|
            csv << [person.name, person.username, person.friends_count, person.followers_count, person.statuses_count]
          end
        end
        outfile.close
        SystemMessage.add_message("info", "Write stats to disk", project.name + " stats were written to disk.")          
      end
    end
  end
  
  #def add_members_to_my_list(listname)
  #  l = @@twitter.lists :name => listname
  #  twitter_ids = project.persons.collect{|p| p.twitter_id}
    #twitter_ids.each do |id|
    # @@twitter.list_add_members(TWITTER_USERNAME, l.lists.first.id, id )    
    #end
    #
  #end
  
  #TODO
  #Break this function into a set of smaller ones since its hard to read and debug
  def generate_most_listed_members
      seen_lists = []
      seen_membersets = []
      @tmp_persons = []
      self.persons.each do |person|
        #puts person.username
        @tmp_persons << {:username => person.username, :list_count => 1,
          :uri => "http://www.twitter.com/#{person.username}", :followers => person.followers_count,
          :friends => person.friends_count}
      end 
      self.lists.each do |list|
        if list.name.include? self.keyword
          if !seen_lists.include? list.uri #If we have not encountered a list with a similar uri before
              if list.members
                membernames = list.members.collect{|a| a[:username]} # Check if there are lists that contain the same people 
                max = 0            
                seen_membersets.each do |m|
                  overlap = m & membernames              
                  result = overlap.count.to_f/m.count
                  if result > max
                    max = result                
                  end
                end
                if max < 0.99 # If there happens to be no lists that already have the same members 99% similarity
                  puts "#{@tmp_persons.count} Analyzing list #{list.uri}. Overlap with memberset #{max}"
                  list.members.each do |member|
                    tmp_user = @tmp_persons.find{|i| i[:username] == member[:username]} # Look if that person is already on the list
                    if tmp_user != nil
                      tmp_user[:list_count] += 1
                    else
                      @tmp_persons << {:username => member[:username], :list_count => 1,
                        :uri => "http://www.twitter.com/#{member[:username]}", :followers => member[:followers_count],
                        :friends => member[:friends_count]}
                    end
                  end
                else
                  puts "List overlap for #{list.uri} with #{membernames.count} members"
                end
                seen_membersets << membernames        
              end                            
            seen_lists << list.uri     
          end
        end
      end      
      
      #Sort these persons according to their listings
      sorted = @tmp_persons.sort{|a,b| a[:list_count] <=> b[:list_count]}.reverse
      
      #Dump the results of this calculation to a csv file
      outfile = File.open("data/" + self.keyword + "_sorted_members.csv",'w')
      CSV::Writer.generate(outfile) do |csv|
        csv << ["Username", "Followers", "List Count", "URI"]
        sorted.each do |member|
          csv << [member[:username], member[:followers], member[:list_count], member[:uri]]
        end
      end
      outfile.close
      return sorted
  end
  
  def add_people_from_wefollow(pages)
    for page in 1..pages
        if page == 1
          uri = URI.parse(WEFOLLOW_BASE_URL + self.keyword + "/followers") 
        else
          uri = URI.parse(WEFOLLOW_BASE_URL + self.keyword + "/page#{page}" + "/followers")   
        end        
        puts uri
        begin
          @@wefollow_scraper.scrape(uri).each do |person|
            result_string = "http://twitter.com/" + person.name
            puts result_string
            username = URI.parse(result_string).path.reverse.chop.reverse
            maxfriends = 10000
            category = ""
            Delayed::Job.enqueue(CollectPersonJob.new(username,self.id,maxfriends,category))  
          end
        rescue
          puts "Couldnt find any page for #{uri}"
        end
    end

  end
  
  #Tries to find all connections for a given project
  def find_all_connections(friend = true, follower = false)
    i= 0
    values = []
    persons_ids = []
    persons = Project.find(self.id).persons    
    persons.each do |person|
      persons_ids << person.twitter_id
    end    
    persons.each do |person|      
      i = i+1
      if friend
        puts("Analyzing ( " + i.to_s + "/" + persons.count.to_s + ") " + person.username + " for friend connections.")          
        friends_ids_hash = person.friends_ids_hash
        persons_ids.each do |person_id|
          if friends_ids_hash.include?(person_id)
            values << [person.username.to_s, Person.find_by_twitter_id(person_id).username]
          end
        end        
      end
      if follower
        puts("Analyzing ( " + i.to_s + "/" + persons.count.to_s + ") " + person.username + " for follower connections.")          
        follower_ids_hash = person.follower_ids_hash
        persons_ids.each do |person_id|
          if follower_ids_hash.include?(person_id)
            values << [person.username.to_s, Person.find_by_twitter_id(person_id).username]
          end
        end  
      end
    end
    return values 
  end
  
  def self.find_all_persons_connections(persons)
    i= 0
    values = []
    persons_ids = []
    persons.each do |person|
      persons_ids << person.twitter_id
    end
    persons.each do |person|      
      i = i+1
      puts("Analyzing ( " + i.to_s + "/" + persons.count.to_s + ") " + person.username + " for friend connections.")          
      friends_ids_hash = person.friends_ids_hash
      persons_ids.each do |person_id|
        if friends_ids_hash.include?(person_id)
          values << [person.twitter_id, person_id]
        end
      end       
    end
    return values
  end
  
  #For  a given project
  #For all persons tweets in the project check if they have been retweeted by other members in the community
  #def find_delayed_retweet_connections(friend = true,follower = false,category = false)    
  #  usernames = persons.collect{|p| p.username}.uniq
  #  
  #  persons[0..1000].each do |person|
  #    Delayed::Job.enqueue(AggregateRtConnectionsJob.new(person.id,self.id, usernames))
  #  end
  #  
  #  wait_for_jobs("AggregateRtConnectionsJob")
  #  return_rt_connections
  #end
  
  #def return_rt_connections
  #  values = []
  #  persons[0..1000].each do |person|      
  #    filename = "#{RAILS_ROOT}/analysis/data/tmp/person_#{person.id}_project_#{self.id}_RT.edges"
  #    puts "Working on #{filename}"
  #    values += FasterCSV.read(filename)
  #  end
  #  
  #  #Merge counted pairs
  #  hash = values.group_by { |first, second, third| [first,second] }
  #  return hash.map{|k,v| [k,v.count].flatten}
  #end
  
  #Tested in Project spec
  #This is part of a delayed Job
  #def self.find_delayed_retweet_connections_for_person(person_id, project_id, usernames = [])    
  #  person = Person.find(person_id)
  #  filename = "#{RAILS_ROOT}/analysis/data/tmp/person_#{person_id}_project_#{project_id}_RT.edges"
  #  outfile = File.open(filename, "w+")    
  #  person.feed_entries.each do |tweet|
  #    tweet.retweet_ids.each do |retweet|       
  #      if usernames.include? retweet[:person]                    
  #        outfile.puts "#{retweet[:person]},#{person.username},#{1}"
  #      end
  #    end
  #  end    
  #end
  
  # For a given project it:
  # Looks through the people contained in a project
  # and for each person it goes through its tweets and looks if that person
  # is mentioning a person in the project. If it finds a mention of the other person
  # it also checks if that is maybe a retweet of that person
  # This makes sure that we only get the @ communication without the RT.
  # Everytime we find somebody we set the value up.
  # Tested in project spec
  def find_all_valued_connections(friend = true, follower = false, category = false)
    if category
      puts "COMPUTING CATEGORY only @ Interactions"
    end
    values = []
    usernames = persons.collect{|p| p.username}
    i = 0
    persons.each do |person|
      i += 1
      puts("Analyzing ( " + i.to_s + "/" + persons.count.to_s + ") " + person.username + " for talk connections.")          
      person.feed_entries.each do |tweet|
        #puts "#Analyzing tweet #{tweet.id}"
        usernames.each do |tmp_user|
          if tweet.text.include?("@" + tmp_user + " ") && !tweet.text.include?("RT")
            #If we compute only persons from the same category.
            if category 
              if person.category != Person.find_by_username(tmp_user).category
                if tweet.retweet_ids == []
                  values << [person.username,tmp_user,1]  
                end                             
              end
            else
              #if the tweet has not been retweeted hence is not a retweet
              if tweet.retweet_ids == [] && person.username != tmp_user
                values << [person.username,tmp_user,1]  
              end             
            end
          end                  
        end
      end      
    end
    #Merge counted pairs
    hash = values.group_by { |first, second, third| [first,second] }
    return hash.map{|k,v| [k,v.count].flatten}  
  end
  
  # A version that used delayed jobs to split the work among a lot of workers
  # Deprecated because the bottleneck was querying the DB
  #def self.find_at_connections_for_person_and_project(person_id,project_id,usernames)
  #  person = Person.find(person_id)
  #  project = Project.find(project_id)
  #  filename = "#{RAILS_ROOT}/analysis/data/tmp/person_#{person.id}_project_#{project.id}_AT.edges"
  #  if File.exists? filename
  #    puts "Skipping person #{person.username}"
  #  else
  #    outfile = File.open(filename, "w+")
  #    person.feed_entries.each do |tweet|        
  #      usernames.each do |tmp_user|
  #        if tmp_user != person.username && tweet.retweet_ids == [] && tweet.text.include?("@#{tmp_user} ") && !tweet.text.include?("RT")
  #          puts tweet.text
  #          outfile.puts "#{person.username},#{tmp_user},#{1},#{tweet.id}"
  #        end
  #      end
  #    end
  #    outfile.close
  #  end      
  #end

  
  # A version that used delayed jobs to split the work among a lot of workers
  # Deprecated because the bottleneck was querying the DB
  # Same as find all valued connections only trying to make it faster
  #def find_all_at_connections(friend = true, follower = false, category = false)            
  #  usernames = persons.collect{|p| p.username}
  #  persons.each do |person|
  #    Delayed::Job.enqueue(AggregateAtConnectionsJob.new(person.id,self.id,usernames))
  #  end    
  #  wait_for_jobs("AggregateAtConnectionsJob")
  #  self.return_all_at_connections
  #end
  #  
  #def return_all_at_connections    
  #  values = []
  #  persons.each do |person|      
  #    filename = "#{RAILS_ROOT}/analysis/data/tmp/person_#{person.id}_project_#{self.id}_AT.edges"
  #    puts "Working on #{filename}"
  #    values += FasterCSV.read(filename)
  #  end
  #  #system("rm *.edges")
  #  #Merge counted pairs
  #  hash = values.group_by { |first, second, third| [first,second] }
  #  return hash.map{|k,v| [k,v.count].flatten}  
  #end
  
  # A version that used solr but was inefficiently querying the db
  # Deprecated because of inefficient runtime
  #def find_at_connections2    
  #  usernames = persons.collect{|p| p.username}
  #  values = []    
  #  persons.each do |person|
  #    puts "Working on person  #{person.username}"
  #    t1 = Time.now
  #    usernames.each do |username|
  #            if person.username != username # Dont collect self referentiations
  #                    search = FeedEntry.search do
  #                            with(:person_id, person.id)
  #                            fulltext "@#{username}"                              
  #                    end                      
  #                    search.results.each do |result|
  #                            #This is not a retweet
  #                            if result.retweet_ids == [] && !result.text.include?("RT") && result.text.include?("@#{username} ")
  #                                    values << [person.username, username, 1]
  #                            end
  #                    end
  #            end
  #    end
  #    t2 = Time.now
  #    puts "Time per person: #{t2- t1}."
  #  end	
  #  #Aggregate 
  #  hash = values.group_by { |first, second, third| [first,second] }    
  #  hash.map{|k,v| [k,v.count].flatten}    
  #end
  
  # Looks through the people contained in a project
  # and for each person it goes through its tweets and looks if that person
  # is mentioned in the project.
  # An @ Edge is when:
  # 1. It is not retweeted
  # 2. It does not contain "RT"
  # 3. The person does not reference himself in his own tweets
  # Tested in project spec
  def find_at_connections_fastest
    users = {}    
    persons.each do |person|        
	users[person.id] = person.username
    end
    values = []
    i = 0
    persons.each do |person|
      i += 1
      t1 = Time.now
      search = FeedEntry.search do        
        without(:person_id,person.id)
        fulltext "@#{person.username} -RT" #Find those Feeds that mention this person
	paginate :page => 1, :per_page => 10000 #Make sure we dont paginate	
      end
      j = 0
      search.results.each do |result|
        if users.keys.include?(result.person_id) && result.person_id != person.id # No self @
          if result.retweet_ids == [] && !result.text.include?("RT") && result.text.include?("@#{person.username} ")
            j += 1
            values << [person.username, users[result.person_id], 1]
          end
        end
      end
      t2 = Time.now      
      puts "Person #{i}. Time per person: #{t2- t1}. Total pages #{search.results.total_pages}. Total results #{search.total}. Filtered: #{j}"
    end
    #Aggregate 
    hash = values.group_by { |first, second, third| [first,second] }    
    hash.map{|k,v| [k,v.count].flatten}    
  end

  def self.dump_net(net)
    CSV::Writer.generate("NET_#{net.count}.csv") do |csv|
      csv << ["DL n=100"]
      csv << ["format = edgelist1"]
      csv << ["labels embedded:"]
      csv << ["data:"]
      net.each do |entry|
        csv << [entry[0], entry[1], entry[2]]
      end
    end    
  end
  
  def dump_FF_edgelist
    net = self.find_all_connections
    File.open("#{RAILS_ROOT}/analysis/data/#{self.id}_FF.edgelist", "w+") do |file|
      net.each do |row|
        file.puts "#{row[0]} #{row[1]} 1" # Strength is always 1 in FF networks
      end
    end   
  end
  
  def dump_AT_edgelist
    net = self.find_at_connections_fastest
    File.open("#{RAILS_ROOT}/analysis/data/#{self.id}_AT.edgelist", "w+") do |file|
      net.each do |row|
        file.puts "#{row[0]} #{row[1]} #{row[2]}"
      end
    end        
  end
  
  def dump_RT_edgelist
    net = self.find_all_retweet_connections
    File.open("#{RAILS_ROOT}/analysis/data/#{self.id}_RT.edgelist", "w+") do |file|
      net.each do |row|
        file.puts "#{row[0]} #{row[1]} #{row[2]}"
      end
    end    
  end
  
  def dump_all_networks
    self.dump_FF_edgelist
    self.dump_AT_edgelist
    self.dump_RT_edgelist
  end
  
  def  find_all_list_connections
    values = []
    self.lists.each do |list|
      if list.name.include? self.keyword        
        puts "#{values.count} Analyzing list members of list #{list.name}"
        if list.members
          membernames = list.members.collect{|l| l[:username]}
          #Create couples of 2
          membernames.combination(2).each do |couple|
            values << [couple.first, couple.last]
          end
        end
      end
    end
    listed_members = self.generate_most_listed_members
    most_listed = listed_members.collect{|m| m[:username]}[0..100]
    values.delete_if {|v| !most_listed.include?(v[0]) or !most_listed.include?(v[1]) }    
    #Merge counted pairs
    hash = values.group_by { |first, second| [first,second] }
    return hash.map{|k,v| [k,v.count].flatten}
  end

  
  # Analytic function that returns the amount of collected tweets vs. the
  # amount of tweets that should have had been collected according to the statuses_count
  def get_tweet_delta
    puts "The delta are due to the 'include rts' function that filters out tweets not originating from that person"
    r = {}
    r[:count] = 0
    r[:message] = []
    r[:persons] = []
     self.persons.each do |person|
       if person.statuses_count != person.feed_entries.count
         person.statuses_count < 3200 ? max = person.statuses_count : max = 3200  
         r[:message] << "Person Username: #{person.username} max: #{max} delta: #{max - person.feed_entries.count}"
         r[:count] += max - person.feed_entries.count
         r[:persons] << person
       end
     end     
     return r
  end
  
  #Analytic function that returns the delta between the collected retweets and
  #and how many should HAVE HAD been collected according to the retweet-count.
  def get_retweet_delta
    r = {}
    r[:count] = 0
    r[:message] = []
    r[:feeds] = []
    self.persons.each do |person|
      person.feed_entries.each do |f|
       if f.retweet_count.to_i != f.retweet_ids.count          
          delta = f.retweet_count.to_i - f.retweet_ids.count
          if delta > 1
            r[:message] << "Person Username: #{person.username} tweet: #{f.guid} delta: #{delta}"
            r[:feeds] << f
          end
          r[:count] += delta
       end         
      end
    end     
    return r
  end
  
  def find_all_id_connections(friend = true, follower = false)
    i= 0
    values = []
    persons_ids = []
    persons = Project.find(self.id).persons    
    persons.each do |person|
      persons_ids << person.twitter_id
    end    
    persons.each do |person|      
      i = i+1
      if friend
        puts("Analyzing ( " + i.to_s + "/" + persons.count.to_s + ") " + person.username + " for friend connections.")          
        friends_ids_hash = person.friends_ids_hash
        persons_ids.each do |person_id|
          if friends_ids_hash.include?(person_id)
            values << [person_id, person.twitter_id]
          end
        end        
      end
      if follower
        puts("Analyzing ( " + i.to_s + "/" + persons.count.to_s + ") " + person.username + " for follower connections.")          
        follower_ids_hash = person.follower_ids_hash
        persons_ids.each do |person_id|
          if follower_ids_hash.include?(person_id)
            values << [person.twitter_id, person_id]
          end
        end  
      end
    end
    return values 
  end
  
  def feed_entries(limit)
    FeedEntry.find(:all, :conditions => [ "person_id IN (?)", self.persons], :limit => limit)    
  end
  

  def feed_entries_count
    r  = 0 
    self.persons.each do |p|
      r += p.feed_entries.count 
    end
    return r
  end
  
  def self.get_remaining_hits
    begin
      r = @@twitter.rate_limit_status.remaining_hits
      if r < 1000
        r = "timeout"
      end
    rescue
      r = "timeout"
    end    
    return r
  end
  
end
