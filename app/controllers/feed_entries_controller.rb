class FeedEntriesController < ApplicationController
  layout 'default'

  require 'net/http'
  require 'uri'
  require 'rexml/document'
  require 'gnuplot'
  
  
  #API Settings for OPENAMPLIFY
  ApiKey = "s2jhybpryqrr2dzhmu7d8r9jz5e5gmjw"
  ApiPort = 8180
  ApiHost = 'portaltnx.openamplify.com'
  ApiPath = '/AmplifyWeb/AmplifyThis'
    
  # GET /feed_entries
  # GET /feed_entries.xml

  def index
    @project = Project.find(params[:project_id])
    
    #depending if I am showing all entries or only the persons entries.
    @count = 0
    if params[:person_id] == nil
      @show_all = true
      @feed_entries = []
      @grouped_entries = []
      @grouped_by_hashtags = {}
      @grouped_by_replies = {}
      @grouped_urls = {}
      #@project.persons.each do |person|
      #  FeedEntry.find(:all,  :conditions => { :person_id => person}, :order => 'published_at DESC').each do |entry|
      #    @feed_entries << entry
      #  end
      #  FeedEntry.count(:all, :conditions => { :person_id => person}, :order => 'published_at DESC', :group => 'DATE(published_at)').each do |entry|
      #    @grouped_entries << entry
      #  end
      #end
      @feed_entries_count = @project.feed_entries.count
      @feed_entries = @project.feed_entries.paginate :page => params[:page]
    else
      @feed_entries_count = @person.feed_entries.count
      @person = Person.find(params[:person_id])
      @feed_entries = @person.feed_entries.paginate :page => params[:page], :order =>  'updated_at DESC'         
      #@feed_entries = FeedEntry.find(:all,  :conditions => { :person_id => @person.id}, :order => 'published_at DESC')
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @feed_entries }
    end
  end

  def show_analysis
    @person = Person.find(params[:person_id])
    @project = @person.project
    
    @feed_entries = FeedEntry.find(:all,  :conditions => { :person_id => @person.id}, :order => 'published_at DESC')

    @grouped_entries = FeedEntry.count(:all, :conditions => { :person_id => @person.id}, :order => 'published_at DESC', :group => 'DATE(published_at)')
    
    #by hashtags
    @grouped_by_hashtags = {}
    @person.feed_entries.collect{|f| f.get_hash_tags}.flatten.group_by{|x| x}.each{|k,v| @grouped_by_hashtags[k]=v.length}
    
    #by @
    @grouped_by_replies = {}
    @person.feed_entries.collect{|f| f.get_at_tags}.flatten.group_by{|x| x}.each{|k,v| @grouped_by_replies[k]=v.length}
    
    #by urls
    @grouped_urls = {}
    #expanded urls
    #@person.feed_entries.collect{|f| URI.parse(f.get_expanded_urls.to_s.lstrip.rstrip).host}.flatten.group_by{|x| x}.each{|k,v| @grouped_urls[k] = v.length}
    #short urls
    @person.feed_entries.collect{|f| URI.parse(f.get_expanded_urls.to_s.lstrip.rstrip).host}.flatten.compact.group_by{|x| x}.each{|k,v| @grouped_urls[k] = v.length}    
    
    #collect all words of all feeds
    words = ""
    @feed_entries.each do |entry|
      words << " " + entry.text
    end 
    
    #collect word frequencies
    @freqs = word_frequencies(words)
    
    #collect proper nouns
    @proper_nouns = {}
    #collect_proper_nouns(words)
    
    #create grouped entries by date:
    @grouped_entries = @grouped_entries.sort_by{|x| [x]}
  end
  
  def create_retweet_network    
    render :update do |page|
      page.redirect_to :action => "generate_retweet_network", :feed_id => params[:feed_id], :project_id => params[:project_id]
    end    
  end
  
  def create_full_reetweet_nework
    render :update do |page|
      page.redirect_to :action => "generate_full_retweet_network", :feed_id => params[:feed_id], :project_id => params[:project_id]
    end   
  end

  
  def generate_full_retweet_network
    o_tweet = FeedEntry.find(params[:feed_id])
    origin_date = o_tweet.published_at
    
    feeds =[]
    
    #B
    #feeds = Project.last.persons.first.feed_entries[0..100]        
    #l = Marshal.load(File.open("r.data"))    
    #l[2689..2789].each do |item|
    #      feeds << FeedEntry.find(item[:id])
    #end
    
    tweets =[]
    persons = []
    origin = o_tweet.person   
    results = FeedEntry.create_retweet_network(params[:feed_id],params[:project_id])
    tweets += FeedEntry.mark_isolates(results[:tweets],o_tweet)
    
    #B
    #feeds.each do |feed|
    #  results = FeedEntry.create_retweet_network(feed.id,params[:project_id])
    #  tweets += results[:tweets]
    #  persons += results[:persons]        
    #end
    
    tweets = FeedEntry.mark_isolates(tweets,o_tweet)
    
    tweets.sort! {|a,b| DateTime.parse(a[:published_at]) <=> DateTime.parse(b[:published_at])}
    start_date = tweets.collect{|t| DateTime.parse(t[:published_at])}.min
    end_date = tweets.collect{|t| DateTime.parse(t[:published_at])}.max
    retweet_net = Project.find_all_persons_connections(persons)
        
    #generate image
    #FeedEntry.generate_plot(tweets,params[:feed_id].to_s)    
    
    CSV::Writer.generate(output = "") do |csv|
        csv << ["<?xml version='1.0' encoding='UTF-8'?>"]
        csv << ["<gexf xmlns='http://www.gexf.net/1.1draft' version='1.1'>"]
        csv << ["<meta lastmodifieddate='"+ Time.now.strftime("%Y-%d-%m") + "'>"]
        csv << ["<creator>plotti@gmx.net</creator>"]
        csv << ["<default>yellow</default>"]
        csv << ["<description>" + o_tweet.id.to_s + "</description>"]
        csv << ["</meta>"]
        csv << ["<graph mode='dynamic' defaultedgetype='directed' start='" + 0.to_s + "' end='" + (tweets.count+1).to_s + "'>"]
        csv << ["<attributes class='node' mode='static'>"]
        csv << ["<attribute id='0' title='retweets' type='string'/>"]
        csv << ["<attribute id='1' title='followers' type='integer'/>"]
        csv << ["<attribute id='2' title='hours_passed' type='integer' />"]
        csv << ["<attribute id='3' title='isolate' type='string' />"]
        csv << ["</attributes>"]
        csv << ["<nodes>"]        
        j = 1       
        tweets.each do |tweet|
          if Person.find_by_username(tweet[:person]) != nil          
            j+= 1          
            csv << ["<node id='"+ Person.find_by_username(tweet[:person]).twitter_id.to_s + "' label='" + tweet[:person].downcase + " (" + DateTime.parse(tweet[:published_at]).strftime("%d.%m %H:%M") + ")' start='" + j.to_s + "' end='" + (tweets.count + 1).to_s + "' >"]
            csv << ["<attvalues>"]
            csv << ["<attvalue for='0' value='" + tweet[:published_at].to_s + "'  />"]
            csv << ["<attvalue for='1' value='" + tweet[:followers_count].to_s + "'  />"]
            hour_diff = ((origin_date - DateTime.parse(tweet[:published_at]))/(3600)).to_i.abs
            csv << ["<attvalue for='2' value='" + hour_diff.to_s + "' />"]
            csv << ["<attvalue for='3' value='" + tweet[:isolate_status].to_s + "' />"]
            csv << ["</attvalues>"]
            csv << ["</node>"]
          end
        end
        #persons.each do |person| 
         # if !tweets.collect{|t| t.user.screen_name}.include?(person.username)
            csv << ["<node id='"+ origin.twitter_id.to_s + "' label='" + origin.username + " (" + o_tweet.published_at.utc.strftime("%d.%m %H:%M") + ")' start='1' end='" + (tweets.count + 1).to_s  + "'  >"]
            csv << ["<attvalues>"]
            csv << ["<attvalue for='0' value='" + o_tweet.published_at.to_s + "'  />"]
            csv << ["<attvalue for='1' value='" + origin.followers_count.to_s + "'  />"]
            csv << ["<attvalue for='2' value='0' />"]
            csv << ["<attvalue for='3' value='origin' />"] 
            csv << ["</attvalues>"]            
            csv << ["</node>"]
          #end
        #end
        csv << ["</nodes>"]
        csv << ["<edges>"]
        i = 1
        retweet_net.each do |entry|
          csv<< ["<edge id='" + i.to_s + "' source='" + entry[0].to_s + "' target='" + entry[1].to_s + "' />"]
          i += 1
        end
        csv << ["</edges>"]
        csv << ["</graph>"]
        csv << ["</gexf>"]
      end
      send_data(output,:filename => params[:feed_id].to_s + "_SNA_DYN.gexf")
  end
  
  def generate_retweet_network            
      tweet = FeedEntry.find(params[:feed_id])      
      results = FeedEntry.create_retweet_network(params[:feed_id],params[:project_id])
      tweets = FeedEntry.mark_isolates(results[:tweets])
      persons = results[:persons]        
    
      tweets.sort! {|a,b| DateTime.parse(a.created_at) <=> DateTime.parse(b.created_at)}
      start_date = DateTime.parse(tweets.collect{|t| t.created_at}.min)
      end_date = DateTime.parse(tweets.collect{|t| t.created_at}.max)
      retweet_net = Project.find_all_persons_connections(persons)      
      
      persons_done = []
      diffusion_count = {}
      tweets.each do |tweet|          
          tweeter = Person.find_by_username(tweet.user.screen_name)
          diffusion_count[tweeter.username] = 0          
          persons_done.each do |person|
            if tweeter.friends_ids.include?(person.twitter_id)
              puts "Diffusion count for #{person.username} is #{diffusion_count[person.username]}"
              diffusion_count[person.username] += 1
            end  
          end
          persons_done << tweeter
      end
      
      CSV::Writer.generate(output = "") do |csv|
        csv << ["<?xml version='1.0' encoding='UTF-8'?>"]
        csv << ["<gexf xmlns='http://www.gexf.net/1.1draft' version='1.1'>"]
        csv << ["<meta lastmodifieddate='"+ Time.now.strftime("%Y-%d-%m") + "'>"]
        csv << ["<creator>plotti@gmx.net</creator>"]
        csv << ["<default>yellow</default>"]
        csv << ["<description>" + tweet.id.to_s + "</description>"]
        csv << ["</meta>"]
        csv << ["<graph mode='dynamic' defaultedgetype='directed' start='" + 0.to_s + "' end='" + tweets.count.to_s + "'>"]
        csv << ["<attributes class='node' mode='dynamic'>"]
        csv << ["<attribute id='0' title='retweets' type='string'/>"]
        csv << ["</attributes>"]
        csv << ["<attributes class='node' mode='static'>"]
        csv << ["<attribute id='1' title='diffusion_count' type='float'/>"]
        csv << ["</attributes>"]
        csv << ["<nodes>"]
        j = 0
        
        tweets.each do |tweet|
          j+= 1
          csv << ["<node id='"+ tweet.user.id.to_s + "' label='" + tweet.user.screen_name.downcase + " (" + DateTime.parse(tweet.created_at).strftime("%d.%m %H:%M") + ")' start='" + j.to_s + "' end='" + tweets.count.to_s + "' >"]
          csv << ["<attvalues>"]
          csv << ["<attvalue for='0' value='" + tweet.created_at.to_s + "'/>"]
          csv << ["<attvalue for='1' value='" + diffusion_count[tweet.user.screen_name].to_s + "'/>"]
          csv << ["</attvalues>"]
          csv << ["</node>"]
        end
        csv << ["</nodes>"]
        csv << ["<edges>"]
        i = 1
        retweet_net.each do |entry|
          csv<< ["<edge id='" + i.to_s + "' source='" + entry[0].to_s + "' target='" + entry[1].to_s + "' />"]
          i += 1
        end
        csv << ["</edges>"]
        csv << ["</graph>"]
        csv << ["</gexf>"]
      end
      send_data(output,:filename => params[:feed_id].to_s + "_SNA_DYN.gexf")
  end
  
  def collect_retweets
    person = Person.find(params[:id])        
    person.feed_entries.each do |entry|
      Delayed::Job.enqueue(CollectRetweetIdsJob.new(entry.id))      
    end    
    respond_to do |format|
      format.js do
        render :update do |page|
          flash[:notice] = 'Retweets for this person are being collected... It might take a time..'
        end
      end
    end
  end
  
  def word_frequencies(text)
    #remove urls and username from entries and aggregate to one long text
    URI.extract(text).each do |entry|
      text = text.sub(entry, " ")
    end
        
    #Remove Stopwords
    STOP_WORDS.each do |stopword|  text.gsub!(/(\s|^)#{stopword}\s/i, " ") end
    
    #wordcount
    text = text.split(/[^a-zA-Z]/)
    #text = text.delete("")  
    
    freqs = Hash.new(0)
    text.each { |word| freqs[word] += 1 }
    freqs = freqs.sort_by {|x,y| y }      #sort by highes occurance        

    return freqs
  
  end
  
  def export_keyword_count  
    render :update do |page|
        page.redirect_to :action => "generate_keyword_count", :project_id => params[:id]
    end
  end
    
  def generate_keyword_count
    project = Project.find(params[:project_id])
    content_type = if request.user_agent =~ /windows/i
                     ' application/vnd.ms-excel '
                   else
                     ' text/csv '
                  end

    keywords = %w(tehran rafsanjani neda ahmadinejad basij gr88 iran iranelection iranian khameni mousavi mousavi1388 #iranelection #iran)    
    
    CSV::Writer.generate(output = "") do |csv|
      csv << ["Person", "Total Entries", "Total Keyword Count", "tehran", "rafsanjani", "neda",  "ahmadinejad",
              "basij", "gr88", "iran", "iranelection",  "iranian", "khameni", "mousavi",
              "mousavi1388", "#iranelection", "#iran"]
      i = 0
      project.persons.each do |person|
        i = i+1
        puts "Analyzing "+ person.username + "(" + i.to_s + "/" + project.persons.count.to_s + ")"
        counter = {}
        keywords.each do |keyword|
          counter[keyword] = 0          
          person.feed_entries.each do |entry|
            # throw away tweets more than a month ago
            if Time.now.month - entry.published_at.month < 1          
              if entry.text.downcase.include?(keyword)            
                counter[keyword] = counter[keyword] + 1            
              end
            end
          end
        end
        csv << [person.username, person.feed_entries.count, counter.collect{|k,v| v}.sum,
              counter["tehran"], counter["rafsanjani"], counter["neda"],  counter["ahmadinejad"],
              counter["basij"], counter["gr88"], counter["iran"], counter["iranelection"],
              counter["iranian"], counter["khameni"], counter["mousavi"],
              counter["mousavi1388"], counter["#iranelection"], counter["#iran"]
              ]
      end
    end
    
    send_data(output,
            :type => content_type,
            :filename => project.name.to_s + "_Keywords.csv")
  end
    
  def export_feeds    
    render :update do |page|
      if params[:id] != nil
        page.redirect_to :action => "generate_csv", :person_id => params[:id]
      else
        page.redirect_to :action => "generate_csv", :project_id => params[:project_id]
      end
    end
  end
  
   #exports Tweets 
  def generate_csv 
    if params[:project_id] == nil
      person = Person.find(params[:person_id])
      feed_entries = person.feed_entries
      export_name = person.username
    else      
      project = Project.find(params[:project_id])
      persons = project.persons
      feed_entries = []
      persons.each do |person|
        person.feed_entries.each do |entry|
          feed_entries << entry
        end        
      end
      export_name = project.name
    end
    
    content_type = if request.user_agent =~ /windows/i
                 ' application/vnd.ms-excel '
               else
                 ' text/csv '
               end
    
    CSV::Writer.generate(output = "") do |csv|
      csv << ["Author", "Entry", "Published at", "Hashtags", "@Replies", "expanded URLs", "RT"]
      i= 0
      feed_entries.each do |entry|
        i= i+1
        puts "Analyzing tweet " + i.to_s + "/" +feed_entries.count.to_s
        csv << [entry.author, entry.text, entry.published_at, entry.get_hash_tags.to_s, entry.get_at_tags.to_s, entry.get_expanded_urls, entry.text.include?("RT")]
      end
    end
    send_data(output,
            :type => content_type,
            :filename => export_name.to_s + "_Feeds.csv")
  end

  # GET /feed_entries/1
  # GET /feed_entries/1.xml
  def show
    @feed_entry = FeedEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @feed_entry }
    end
  end

  # GET /feed_entries/new
  # GET /feed_entries/new.xml
  def new
    @feed_entry = FeedEntry.new
    @project = Project.find(params[:project_id])
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feed_entry }
    end
  end

  # GET /feed_entries/1/edit
  def edit
    @feed_entry = FeedEntry.find(params[:id])
  end

  # POST /feed_entries
  # POST /feed_entries.xml
  def create
    @feed_entry = FeedEntry.new(params[:feed_entry])

    respond_to do |format|
      if @feed_entry.save
        flash[:notice] = 'FeedEntry was successfully created.'
        format.html { redirect_to(@feed_entry) }
        format.xml  { render :xml => @feed_entry, :status => :created, :location => @feed_entry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @feed_entry.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  #Gather all rss for a given person 
  def collect_all_entries
    person = Person.find(params[:id])
    Delayed::Job.enqueue(CollectAllFeedEntriesJob.new(person.id))

    respond_to do |format|
      format.js do
        render :update do |page|
          flash[:notice] = 'FeedEntries will be collected. Around ' + person.statuses_count.to_s + ' Feed entries will be gathered.'
          page.reload
        end
      end
    end
  end
  
  # PUT /feed_entries/1
  # PUT /feed_entries/1.xml
  def update
    @feed_entry = FeedEntry.find(params[:id])

    respond_to do |format|
      if @feed_entry.update_attributes(params[:feed_entry])
        flash[:notice] = 'FeedEntry was successfully updated.'
        format.html { redirect_to(@feed_entry) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @feed_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /feed_entries/1
  # DELETE /feed_entries/1.xml
  def destroy
    @feed_entry = FeedEntry.find(params[:id])
    @feed_entry.destroy

    respond_to do |format|
      format.html { redirect_to(feed_entries_url) }
      format.xml  { head :ok }
    end
  end
  
  def collect_proper_nouns(text)
    input_type = "inputText"
    URI.extract(text).each do |entry| text = text.sub(entry, "") end
    hash = Hash.new(0)
    begin 
      http = Net::HTTP.new(ApiHost, ApiPort)
      response = http.post(ApiPath, "apiKey=#{ApiKey}&#{input_type}=#{URI::escape(text)}")
      doc= REXML::Document.new(response.read_body)
      proper_nouns = Hash.new(0)    
      values = doc.each_element('//ProperNouns//Topic//Value//text()')
      keys = doc.each_element('//ProperNouns//Topic//Name//text()')
      keys.size.times { |i| hash[ keys[i].to_s ] = values[i].to_s.to_i }
    rescue
      SystemMessage.add_message("error", "Collect Proper Nouns", "Could not establish connection and collect proper nouns.")
    end
    return hash
  end

end
