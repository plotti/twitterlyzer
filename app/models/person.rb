class Person < ActiveRecord::Base
  
  require 'open-uri'  
  require 'json'
  require 'typhoeus'
  require 'twitter'
  require 'ar-extensions'  
  require 'ar-extensions/adapters/mysql'
  require 'ar-extensions/import/mysql' 
  include Typhoeus
  require 'pstore'
  
  #associations
  has_and_belongs_to_many :project
  has_many :feed_entries, :dependent => :destroy
  after_destroy :destroy_relations
  
  #Destroys the files on the HDD
  #TODO TEST it!
  def destroy_relations
    begin
      File.delete FRIENDS_IDS_PATH + self.twitter_id.to_s
      File.delete FOLLOWER_IDS_PATH + self.twitter_ids.to_s
    rescue
      puts "Didnt find the corresponding files."
    end    
  end
  
  #collects the friends of a given user
  #Tested
  def collect_friends twitter_id 
    begin
      puts "COLLECTING Friends IDS OF #{twitter_id}"
      result = @@client.friends.ids? :id => twitter_id, :cursor => -1
      friends_ids = result.ids
      old_cursor = 0
      next_cursor = result.next_cursor
      while old_cursor != next_cursor and next_cursor != 0
        old_cursor = next_cursor
        result = @@client.friends.ids? :id => twitter_id, :cursor => next_cursor
        friends_ids +=  result.ids
        next_cursor = result.next_cursor
      end
    rescue      
      friends_ids = []      
      tmp_person = @@client.users.show? :id => twitter_id
      SystemMessage.add_message("error", "Collect Friends ", "Friends of Person with username: " + tmp_person.screen_name.to_s + " could not be found. Person protection is " + tmp_person.protected.to_s )
      logger.error("ERROR: Collect Friends of person with twitter id " + twitter_id.to_s + "was not possible.")
    end
    if friends_ids != [] 
      friends_ids_hash = Hash.new(0)
      store = PStore.new( FRIENDS_IDS_PATH + twitter_id.to_s)
      store.transaction{store[twitter_id] = friends_ids_hash} #empty store if updating      
      friends_ids.each do |friend_id|
        friends_ids_hash[friend_id] = 1
      end            
      store.transaction{store[twitter_id] = friends_ids_hash} #store entries
    end
  end
  
  # collects the followers of a given user
  # Tested
  def collect_followers twitter_id
    begin
     puts "COLLECTING Follower IDS OF #{twitter_id}"
     result = @@client.followers.ids? :id => twitter_id, :cursor => -1
     follower_ids = result.ids
     old_cursor = 0
     next_cursor = result.next_cursor
     while old_cursor != next_cursor and next_cursor != 0
      old_cursor = next_cursor
      result = @@client.followers.ids? :id => twitter_id, :cursor => next_cursor
      follower_ids += result.ids
      next_cursor = result.next_cursor
     end     
    rescue
      follower_ids = []
      tmp_person = @@client.users.show? :id => twitter_id
      SystemMessage.add_message("error", "Collect Followers", "Followers of Person with twitter id: " + tmp_person.screen_name + " could be not found.")          
    end
    if follower_ids != []      
      follower_ids_hash = Hash.new(0)
      store = PStore.new(FOLLOWER_IDS_PATH + twitter_id.to_s)
      store.transaction{store[twitter_id] = follower_ids_hash} #empty store if updating
      follower_ids.each do |follower_id|
        follower_ids_hash[follower_id] = 1  
      end
      store.transaction{store[twitter_id] = follower_ids_hash} #store values
    end
  end
  
  #returns the lists in which the user is listed
  #Tested
  def self.collect_list_memberships(username, project_id = "")
    while Project.get_remaining_hits == "timeout"
      puts "collect_list_memberships waiting..."
      sleep(60) 
    end
    result = @@twitter.memberships(username, {:cursor => -1})
    lists = result["lists"]
    next_cursor = result["next_cursor"]
    old_next_cursor = 0
    @project = Project.find(project_id)
    puts "Membership Lists Count #{lists.count} next cursor: #{next_cursor}"
    while old_next_cursor != next_cursor and next_cursor != 0
      old_next_cursor = next_cursor
      result = @@twitter.memberships(username, {:cursor => next_cursor})
      lists += result["lists"]
      next_cursor = result["next_cursor"]
      puts "Membership Lists Count #{lists.count} next cursor: #{next_cursor}"
    end
    lists.each do |list|
      #It collects only the lists that match the project keyword
      if list["name"].include? @project.keyword
        List.create(:username => list["user"]["screen_name"], :list_type => "member", :name =>  list["name"],
                    :subscriber_count => list["subscriber_count"],  :member_count => list["member_count"],
                    :description => list["description"], :uri => list["uri"], :slug => list["slug"], :guid => list["id"],
                    :project_id => project_id)
      end
    end    
  end
  
  #returns the lists which have been created by the user
  #Tested
  def self.collect_own_lists(username)
    while Project.get_remaining_hits == "timeout"
      puts "collect_own_lists waiting..."
      sleep(60) 
    end
    result = []
    result = @@twitter.lists(username, {:cursor => -1})
    lists = result["lists"]
    next_cursor = result["next_cursor"]
    old_next_cursor = 0
    puts "Own Lists Count #{lists.count} next cursor: #{next_cursor}"
    while old_next_cursor != next_cursor and next_cursor != 0
      old_next_cursor = next_cursor
      result = @@twitter.lists(username, {:cursor => next_cursor})      
      lists += result["lists"]
      next_cursor = result["next_cursor"]
      puts "Membership Lists Count #{lists.count} next cursor: #{next_cursor}"
    end
    lists.each do |list|
      List.create!(:username => list["user"]["screen_name"], :list_type => "own", :name =>  list["name"],
                  :subscriber_count => list["subscriber_count"],  :member_count => list["member_count"],
                  :description => list["description"], :uri => list["uri"], :slug => list["slug"], :guid => list["id"])
    end    
  end
  
  #returns the lists that the user is following
  #Tested 
  def self.collect_list_subscriptions(username)
    while Project.get_remaining_hits == "timeout"
      puts "collect_list_subscriptions waiting..."
      sleep(60) 
    end
    result = @@twitter.subscriptions(username,{:cursor => -1})
    lists = result["lists"]
    next_cursor = result["next_cursor"]
    old_next_cursor = 0
    puts "Subscribed Lists Count #{lists.count} next cursor: #{next_cursor}"
    
    while old_next_cursor != next_cursor and next_cursor != 0
      old_next_cursor = next_cursor
      result = @@twitter.subscriptions(username,{:cursor => next_cursor})
      lists += result["lists"]
      next_cursor = result["next_cursor"]
    end
    lists.each do |list|
      List.create!(:username => list["user"]["screen_name"], :list_type => "subscribe", :name =>  list["name"],
                  :subscriber_count => list["subscriber_count"],  :member_count => list["member_count"],
                  :description => list["description"], :uri => list["uri"], :slug => list["slug"], :guid => list["id"])
    end
  end
  
  #returns the members of a given list
  #Tested
  def self.collect_list_members(username, list_id,project_id)
    while Project.get_remaining_hits == "timeout"
      puts "collect_list_members waiting..."
      sleep(60) 
    end
    result = @@twitter.list_members(username, list_id, {:cursor => -1})    
    members = result["users"]
    next_cursor = result["next_cursor"]
    old_next_cursor = 0    
    
    while old_next_cursor != next_cursor and next_cursor != 0
      old_next_cursor = next_cursor
      result = @@twitter.list_members(username, list_id, {:cursor => next_cursor})  
      members = members + result["users"]
      next_cursor = result["next_cursor"]
      puts "Member Count #{members.count} next cursor: #{next_cursor}"
    end
    members.each do |member|
      Delayed::Job.enqueue(CollectPersonJob.new(member["id"],project_id,100000))  
    end
    return members
  end
  
  #Collects a person and adds it to the database if not exisiting yet, otherwise retrieves it from the database
  #Tested  
  def self.collect_person(twitter_id, project_id, max_collection, category = "", friends = true, followers = false)                
    while Project.get_remaining_hits == "timeout"
      puts "collect_person waiting..."
      sleep(60) 
    end
    
    # Check if we can find the user in the DB
    if twitter_id.is_a?(Numeric)
      person = Person.find_by_twitter_id(twitter_id)        
    else
      person = Person.find_by_username(twitter_id)
    end    
        
    #Collect Person if not in DB
    if person == nil
      puts "COLLECTING PERSON " + twitter_id.to_s
      if twitter_id.class == "String"
        begin
          person = @@client.users.show? :screen_name => twitter_id
        rescue
        end        
      else
        begin
          person = @@client.users.show? :id => twitter_id
        rescue
        end
      end
      
      if person == nil
        SystemMessage.add_message("error", "Collect Person ",  " Person with twitter id: " + twitter_id.to_s + " was not found. Retrying.")
        logger.error "Person with twitter id: " + twitter_id.to_s + " was not found. Retrying."
      else
        #Store Person      
        person = Person.add_entry(person)
        #Collect Friends IDS
        if friends
          if person.friends_count.to_i < max_collection.to_i
            person.collect_friends(person.twitter_id)
          end          
        end      
        #Collect Followers IDS
        if followers
          if person.followers_count.to_i < max_collection.to_i
            person.collect_followers(person.twitter_id)
          end          
        end
      end
    end
    
    #Store Project
    puts category
    person.update_attribute(:category,category)
    person.save!
    project = Project.find(project_id)
    if !project.persons.include?(person)          
      project.persons << person
      project.save!
    end              
    return person
  end

  #Collects a person and its friends
  #TODO: Test
  def self.collect_person_and_friends(twitter_id, project_id,max)           
    person = Person.collect_person(twitter_id,project_id,max)
    person.friends_ids.each do |friend_id|
      Person.collect_person(friend_id,project_id,max)        
    end
    return person
  end
  
  #Collects a person and its followers
  #TODO: Test
  def self.collect_person_and_followers(twitter_id,project_id,max)
    person = Person.collect_person(twitter_id, project_id, max, "", false, true)    
    person.follower_ids.each do |follower_id|
      Person.collect_person(follower_id, project_id, max)
    end
    return person
  end  
  
  
  #Returns a friends_id hash for a given person
  #TODO: Test
  def friends_ids_hash
    friends_ids_hash = Hash.new()
    store = PStore.new(FRIENDS_IDS_PATH + self.twitter_id.to_s)
    store.transaction{friends_ids_hash = store[self.twitter_id]}
    if friends_ids_hash == nil
      friends_ids_hash = Hash.new(0)
    end
    return friends_ids_hash    
  end
  
  #Returns the friends ids for  a given person
  #TODO: Test
  def friends_ids
    self.friends_ids_hash.keys rescue []
  end
  
  #Returns a follower id hash for a given person
  #TODO: Test  
  def follower_ids_hash
    follower_ids_hash = Hash.new()
    store = PStore.new(FOLLOWER_IDS_PATH + self.twitter_id.to_s)
    store.transaction{follower_ids_hash = store[self.twitter_id]}
    if follower_ids_hash == nil
      follower_ids_hash = Hash.new(0)
    end
    return follower_ids_hash
  end
  
  #Returns the follower ids for  a given person
  #TODO: Test
  def follower_ids
    self.follower_ids_hash.keys rescue []
  end
  
  #Retrieves all feed entries sorted by published date
  #TODO Maybe obsolete
  def get_all_entries
    @feed_entries = FeedEntry.find(:all,  :conditions => { :person_id => self.id}, :order => 'published_at DESC')
  end
  
  #Retrieves the last entry from the person
  #TODO Maybe obsolete
  def get_last_entry
    @entry = FeedEntry.find(:first, :conditions => {:person_id => self.id})
  end
  
  #Retrieves all friends from a person from the database
  def get_all_friends
    friends = []
    self.friends_ids.each do |id|
      unless Person.find_by_twitter_id(id).nil?
        friends  << Person.find_by_twitter_id(id)
      end      
    end
    return friends
  end

  #Retrieves all followers from a person from the database
  def get_all_followers
    followers = []
    self.follower_ids.each do |id|
      unless Person.find_by_twitter_id(id).nil?
        followers << Person.find_by_twitter_id(id)  
      end      
    end
    return followers
  end
  
  def get_retweets
    usernames = project.first.persons.collect{|p| p.username}
    retweets = []
    feed_entries.each do |tweet|
      tweet.retweet_ids.each do |retweet|          
        if usernames.include? retweet[:person]
          retweets <<  [tweet.id,tweet.text,retweet]
        end
      end      
    end
    return retweets
  end
  
  #Updated the person stats and feeds
  #TODO Obsolete
  def self.update_all_persons
    Project.all.each do |project|      
      if project.monitor_feeds == true        
        project.persons.each do |person|
          Delayed::Job.enqueue(UpdatePersonJob.new(person.twitter_id))  
        end
      SystemMessage.add_message("info", "Update all person stats",  "Project " + project.name + " persons (" + project.persons.count.to_s + ") have been scheduled for update.")
      end      
    end
  end
  
  #Update the twitter statistics of a person
  # TODO Obsolete
  def self.update_twitter_stats(twitter_id)
    tmp_person = Person.find_by_twitter_id(twitter_id)
    twitter_person = Person.twitter_user(:params => {:id => twitter_id})
    tmp_person.collect_friends(twitter_id) #update friends ids
    tmp_person.update_attributes(
          :name           => twitter_person['name'],
          :bio            => twitter_person['description'],
          :location       => twitter_person['location'],
          :picture        => twitter_person['profile_image_url'],          
          :time_offset    => twitter_person['time_zone'],
          :friends_count  => twitter_person['friends_count'],
          :followers_count => twitter_person['followers_count'],
          :statuses_count => twitter_person['statuses_count'],
          :last_activity => twitter_person['status']['created_at']
    )    
  end  
  
  #Adds one Person to to DB
  def self.add_entry(twitter_person)
    if twitter_person.statuses_count == 0
      last_update = Date.new(0)
    else
      begin
        last_update = twitter_person.status.created_at
      rescue
        last_update = Date.new(0)
      end
    end
    if Person.all(:conditions => ["twitter_id = ? ", twitter_person.id]) == []
      begin
        create!(
          :name           => twitter_person.name,
          :bio            => twitter_person.description,
          :location       => twitter_person.location,
          :picture        => twitter_person.profile_image_url,
          :private        => twitter_person.protected,
          :acc_created_at => twitter_person.created_at,
          :time_offset    => twitter_person.time_zone,
          :friends_count  => twitter_person.friends_count,
          :followers_count => twitter_person.followers_count,
          :statuses_count => twitter_person.statuses_count,
          :username       => twitter_person.screen_name,
          :twitter_id     => twitter_person.id,
          :last_activity  => last_update
        )
      rescue
        puts "COULD NOT INSERT PERSON"
        SystemMessage.add_message("error", "Add Person ",  " Person with twitter id: " + twitter_person.id.to_s + " could not be created.")
      end
    end
    return Person.find_by_twitter_id(twitter_person.id)
  end
  
end
