class Project < ActiveRecord::Base
  require "graphviz"
  require "csv"
  #require 'igraph'

  #associations
  has_and_belongs_to_many :persons
  has_many :searches
  has_many :system_messages, :as => :messageable
  
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
        logger.info("Analyzing ( " + i.to_s + "/" + persons.count.to_s + ") " + person.username + " for friend connections.")          
        friends_ids_hash = person.friends_ids_hash
        persons_ids.each do |person_id|
          if friends_ids_hash.include?(person_id)
            values << [Person.find_by_twitter_id(person_id).username, person.username.to_s]
          end
        end        
      end
      if follower
        logger.info("Analyzing ( " + i.to_s + "/" + persons.count.to_s + ") " + person.username + " for follower connections.")          
        follower_ids_hash = person.follower_ids_hash
        persons_ids.each do |person_id|
          if follower_ids_hash.include?(person_id)
            values << [Person.find_by_twitter_id(person_id).username, person.username.to_s]
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
          values << [person_id, person.twitter_id]
        end
      end       
    end
    return values
  end
  
  def find_all_retweet_connections(friend = true, follower = false)
    i= 0
    values = []
    persons_hash = []    
    persons = Project.find(self.id).persons    
    persons.each do |person|
      persons_hash << {:id => person.twitter_id, :username => person.username}
    end
    persons.each do |person|
      i = i+1
      puts("Analyzing ( " + i.to_s + "/" + persons.count.to_s + ") " + person.username + " for retweet connections.")
      friends_ids_hash = person.friends_ids_hash
      tweets = person.feed_entries        
      persons_hash.each do |tmp_person|
        v = 0
        if friends_ids_hash.include?(tmp_person[:id])
          v += 0 # do not count friend/follower relation
          tweets.each do |tweet|
            tweet.retweet_ids.each do |retweet|
              if retweet[:person] == tmp_person[:username]
                v += 1
              end
            end
          end
          values << [person.username,tmp_person[:username],v]
        end
      end
    end    
    return values
  end
  
  
  # For a given project it:
  # Looks through the people contained in a project
  # and for each person it goes through its tweets and looks if that person
  # is mentioning a person in the project. If it finds a mention of the other person
  # it also checks if that is maybe a retweet of that person
  # This makes sure that we only get the @ communication without the RT.
  # Everytime we find somebody we set the value up.
  def find_all_valued_connections(friend = true, follower = false)
    i= 0
    values = []
    persons_hash = []    
    persons = Project.find(self.id).persons    
    persons.each do |person|
      persons_hash << {:id => person.twitter_id, :username => person.username}
    end    
    persons.each do |person|
      i = i+1
      if friend
        puts("Analyzing ( " + i.to_s + "/" + persons.count.to_s + ") " + person.username + " for friend connections.")          
        friends_ids_hash = person.friends_ids_hash
        tweets = person.feed_entries        
        persons_hash.each do |tmp_person|
          v = 0
          if friends_ids_hash.include?(tmp_person[:id])
            v += 0 #dont count the friendship relation
            tweets.each do |tweet|
              if tweet.text.include?(tmp_person[:username]) #its a mention of a user
                if tweet.retweet_ids == [] #but its not a retweet
                  v += 1
                end                
              end
            end
            values << [person.username,tmp_person[:username],v]
          end
        end
      end
    end
    return values
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
            values << [person_id, person.twitter_id]
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
  
end
