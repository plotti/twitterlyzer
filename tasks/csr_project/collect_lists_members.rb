# the Original Idea to collect lists and its members as a prototype

class List
  attr_accessor :persons, :categories, :lists, :keyword
  
  require 'rubygems'  
  require 'scrapi'
  require 'csv'
  require 'cgi'  
  require 'grackle'

  #Twitter Client
  CONSUMER_KEY = ""
  CONSUMER_SECRET = ""
  ACCESS_TOKEN = ""
  ACCESS_TOKEN_SECRET = ""
  BASE_URL = "http://twellow.com/category_users/cat_id/"
  TOTAL_PAGES = 5
  MAX_LIST_COUNTER = 200

  
  def initialize(filename,keyword)
    @@client = Grackle::Client.new(:auth=>{
      :type=>:oauth,
      :consumer_key=>CONSUMER_KEY, :consumer_secret=>CONSUMER_SECRET,
      :token=>ACCESS_TOKEN, :token_secret=>ACCESS_TOKEN_SECRET
    })
    @persons = []
    @lists = []
    @categories = []
    read_in_persons(filename)
    @keyword = keyword
  end
  
  #Read in Persons
  def read_in_persons(filename)
    puts "#########Reading in Persons##############"
    begin
      rows = CSV.read(filename)
      rows.each do |row|
        @persons << {:url =>  row[0], :name => URI.parse(row[0]).path.reverse.chop.reverse}
      end
    rescue
    end     
    return @persons
  end
  
  
  #Gather Lists of each person
  def collect_lists
    puts "#########Collecting in Lists##############"
    CSV.open("../data/#{@keyword}_lists.csv",'w') do |csv|
      csv << ["List Name", "ID", "URI", "Person Name", "Person Keywords"]
      @persons.each do |person|
        puts "Analyzing person:#{person[:name]}"    
        next_cursor = -1
        not_found_counter = 0
        while next_cursor != 0 and not_found_counter < MAX_LIST_COUNTER
          begin
            #Get all memberships of that user            
            r = @@client._(person[:name]).lists.memberships? :cursor => next_cursor
            r.lists.each do |list|
              keyword_found = false                    
              #puts "List Name: #{list.name.downcase} Keyword: #{@keyword.downcase}"
              if list.name.downcase.include?(@keyword.downcase)
                keyword_found = true
              end          
              if keyword_found
                puts "C:#{not_found_counter} Found list:#{list.name}"
                not_found_counter = 0
                uri = list.uri
                uri.slice!(0)
                @lists << {:name => list.name, :id => list.id, :uri => uri, :person_name => person[:name], :keywords => @keyword}
                csv << [list.name, list.id, uri, person[:name], @keyword]
              else
                not_found_counter += 1
              end
            end
            next_cursor = r.next_cursor
          rescue 
            puts "C:#{next_cursor} Could not get a list for person #{person[:name]}"
            next_cursor = 0
          end
        end
      end
    end  
  end
  
  def collect_list_members
    puts "#########Collecting Members##############"
    CSV.open("../data/#{@keyword}_members.csv",'w') do |csv|
      csv << ["Username", "Uri", "Followers", "Friends", "List Count", "Category"]
      @tmp_users = []
      @lists.each do |list|
        next_cursor = -1 
        puts "Analyzing list #{list[:name]} (#{list[:uri]}). Users collected: #{@tmp_users.length}"
        while next_cursor != 0
          begin
            r = @@client._(list[:uri]).members? :cursor => next_cursor
            r.users.each do |user|
              tmp_user = @tmp_users.find{|i| i[:name] == user.name}
              if tmp_user != nil
                tmp_user[:list_count] += 1
              else            
                @tmp_users << {:name => user.name, :list_count => 1, :uri => "http://www.twitter.com/#{user.screen_name}", :followers => user.followers_count, :friends => user.friends_count, :category => list[:keywords].last}
              end
            end
            next_cursor = r.next_cursor
          rescue
            puts "List #{list[:name]} could not be obtained."
            next_cursor = 0
          end
        end      
      end
      #Dump users to CSV
      @tmp_users.each do |user|
        csv << [user[:name], user[:uri], user[:followers], user[:friends], user[:list_count], user[:category]]
      end
    end
  end
  
end

########MAIN ###########

##t = Twellow.new
##t.read_in_categories
##
##if t.read_in_persons == []
##  t.collect_persons
##end
##
##if t.read_in_lists == []
##  t.collect_lists  
##end
##
##t.collect_list_members
