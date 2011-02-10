class Twellow
  attr_accessor :persons, :categories, :lists
  
  require 'rubygems'  
  require 'scrapi'
  require 'csv'
  require 'cgi'  
  require 'grackle'

  #Twitter Client
  CONSUMER_KEY = "lPeEtUCou8uFFOBt94h3Q"
  CONSUMER_SECRET = "iBFQqoV9a5qKCiAfitEXFzvkD7jcpSFupG8FBGWE"
  ACCESS_TOKEN = "15533871-abkroGVmE7m1oJGzZ38L29c7o7vDyGGSevx6X25kA"
  ACCESS_TOKEN_SECRET = "pAoyFeGQlHr53BiRSxpTUpVtQW0B0zMRKBHC3hm3s"
  BASE_URL = "http://twellow.com/category_users/cat_id/"
  TOTAL_PAGES = 5
  MAX_LIST_COUNTER = 200

  
  def initialize
    @@client = Grackle::Client.new(:auth=>{
      :type=>:oauth,
      :consumer_key=>CONSUMER_KEY, :consumer_secret=>CONSUMER_SECRET,
      :token=>ACCESS_TOKEN, :token_secret=>ACCESS_TOKEN_SECRET
    })
    @persons = []
    @lists = []
    @categories = []
    
    #Scraper Scraping people
    @scraper = Scraper.define do
      array :items
      #div+div>div.person-box
      process "table.listings-border", :items => Scraper.define {
        process "i>a", :name => "@href"
      }    
      result :items
    end
  
    #Scraper scraping subcategories from category
    @subcategory_scraper = Scraper.define do  
      array :items
      process "table.twellow-tools li", :items => Scraper.define {
          process "a", :name => :text
        }    
      result :items
    end
    
    #Scraper defining Category
    @category_scraper = Scraper.define do
      process "div.user-amount", :category=> :text
      result :category
    end  
     
    @umlauts = {
      '&#187' => '',
      '&amp' => ''    
    }
  end

  
  
  #Read in categories for for scraping
  def read_in_categories  
    puts "#########Reading in Categories##############"
    begin
      File.open("categories.txt").each_line do |line|
          @categories << line.chomp
      end
    rescue
    end    
    return @categories
  end
  
  #Read in Persons
  def read_in_persons
    puts "#########Reading in Persons##############"
    begin
      rows = CSV.read("twellow_persons.csv")
      rows.shift
      rows.each do |row|
        @persons << {:url =>  row[0], :category => row[1], :name =>  row[3], :keywords => row[4].split(/;/)}
      end
    rescue
    end     
    return @persons
  end
  
  #Read in collected lists 
  def read_in_lists
    puts "#########Reading in Lists##############"
    begin
      rows = CSV.read("twellow_lists.csv")
      rows.shift
      rows.each do |row|
        @lists << {:name =>  row[0], :id => row[1], :uri => row[2], :person_name => row[3], :keywords => row[4].split(/;/)}
      end
    rescue
    end    
    return @lists
  end
  
  def collect_persons
    puts "#########Collecting in Persons##############"
    CSV.open("twellow_persons.csv", "w") do |csv|
      csv << ["URL", "Category", "Id", "Name", "Keywords"]
      @categories.each do |category|
        page = 1
        more_pages = true
        while more_pages 
          uri = URI.parse(BASE_URL + category + "/page_num/#{page}?order_by=followers&sort=desc")
          puts uri
          begin
            #Scrape Analyzed Category Name 
            category_keywords = []
            category_string = @category_scraper.scrape(uri).to_s
            category_string.split(/;/).drop(1).each do |string|
              @umlauts.each_pair do |umlaut,entity|
                string.gsub!(umlaut,entity)
                string.lstrip!
                string.rstrip!
              end
                category_keywords << string
            end        
                        
            #Scrape Twellow Users from Website
            @scraper.scrape(uri).each do |person|
              result_string = person.name
              username = URI.parse(person.name).path.reverse.chop.reverse
              @persons << {:url => result_string, :category => category, :name => username, :keywords => category_string}
              csv << [result_string, category_string, category, username, category_keywords.join(";")]
            end
          rescue
            puts "Couldnt find more pages than #{page} for #{uri}"
            more_pages = false
          end
          if page < TOTAL_PAGES
            page += 1
          else
            break
          end        
        end      
      end
    end
  end
    
  
  #Gather Lists of each person
  def collect_lists
    puts "#########Collecting in Lists##############"
    CSV.open('twellow_lists.csv','w') do |csv|
      csv << ["List Name", "ID", "URI", "Person Name", "Person Keywords"]
      @persons.each do |person|
        puts "Analyzing person:#{person[:name]}"    
        next_cursor = -1
        not_found_counter = 0
        while next_cursor != 0 and not_found_counter < MAX_LIST_COUNTER
          begin
            #Get all memberships of that user
            r = @@client.lists.memberships? :user => person[:name], :cursor => next_cursor
            r.lists.each do |list|
              keyword_found = false                    
              if list.name.downcase.include?(person[:keywords].last.downcase)
                keyword_found = true
              end          
              if keyword_found
                puts "C:#{not_found_counter} Found list:#{list.name}"
                not_found_counter = 0
                uri = list.uri
                uri.slice!(0)
                @lists << {:name => list.name, :id => list.id, :uri => uri, :person_name => person[:name], :keywords => person[:keywords]}
                csv << [list.name, list.id, uri, person[:name], person[:keywords].join(";")]
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
    CSV.open('twellow_members.csv','w') do |csv|
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

t = Twellow.new
t.read_in_categories

if t.read_in_persons == []
  t.collect_persons
end

if t.read_in_lists == []
  t.collect_lists  
end

t.collect_list_members
