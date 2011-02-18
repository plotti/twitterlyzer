class ProjectsController < ApplicationController
  # GET /projects
  # GET /projects.xml
  require 'csv'
  layout 'default'
  
  def index
    @projects = Project.all
    @delayed_jobs = Delayed::Job.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projects }
    end
  end
  
  def delete_jobs
    Delayed::Job.delete_all
    respond_to do |format|
      flash[:notice] = "All Delayed Jobs have been deleted!"
      format.js do
        render :update do |page|          
          page.reload
        end
      end
    end
  end
  
  def start_jobs
    system "script/delayed_job start  #{RAILS_ENV} -n 4"
    respond_to do |format|
      flash[:notice] = "4 Worker Threads have been started!"
      format.js do
        render :update do |page|          
          page.reload
        end
      end
    end
  end
  
  def stop_jobs
    system "script/delayed_job stop  #{RAILS_ENV}"
    respond_to do |format|
      flash[:notice] = "4 Worker Threads have been stoped!"
      format.js do
        render :update do |page|          
          page.reload
        end
      end
    end    
  end
  
  # GET /projects/1
  # GET /projects/1.xml
  def show
    @project = Project.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = Project.new(params[:project])

    respond_to do |format|
      if @project.save
        flash[:notice] = 'Project was successfully created.'
        format.html { redirect_to(@project) }
        format.xml  { render :xml => @project, :status => :created, :location => @project }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    @project = Project.find(params[:id])

    respond_to do |format|
      if @project.update_attributes(params[:project])
        flash[:notice] = 'Project was successfully updated.'
        format.html { redirect_to(@project) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def collect_all_project_entries
    @project = Project.find(params[:id])
    total_entries = 0
    
    puts "Analyzing " + @project.name.to_s  + " with " + @project.persons.count.to_s + " persons."    
    
    @project.persons.each do |person|
      if person.private == false
        if person.statuses_count > 3200
          total_entries = total_entries + person.statuses_count - 3200
        else
          total_entries = total_entries + person.statuses_count
        end
      end
      Delayed::Job.enqueue(CollectAllFeedEntriesJob.new(person.id))  
    end    
    
    respond_to do |format|
      flash[:notice] = total_entries.to_s + ' feed entries of the ' + @project.persons.count.to_s + ' people on this project will be collected. Please give it some time to finish.'
      format.js do
        render :update do |page|          
          page.reload
        end
      end
    end    
  end
  
  def collect_all_project_retweets
    @project = Project.find(params[:id])
    total_entries = 0
    
    puts "Analyzing " + @project.name.to_s  + " with " + @project.persons.count.to_s + " persons."
    
    @project.persons.each do |person|
     if person.private == false
       if person.statuses_count > 3200
         total_entries = total_entries + 3200
       else
         total_entries = total_entries + person.statuses_count
       end
     end
     person.feed_entries.each do |feed_entry|
      if feed_entry.retweet_count.to_i > 0
        Delayed::Job.enqueue(CollectRetweetIdsForEntryJob.new(feed_entry.id))         
      end
     end
    end
   
   respond_to do |format|
     flash[:notice] = total_entries.to_s + ' feed entries of the ' + @project.persons.count.to_s + ' people on this project will be analyzed for retweets.'
     format.js do
       render :update do |page|          
         page.reload
       end
     end
   end       
  end
  
  
  def update_all_project_entries
    @project = Project.find(params[:id])
    total_entries = 0
            
    @project.persons.each do |person|
      total_entries = total_entries + person.statuses_count
      Delayed::Job.enqueue(UpdateAllFeedEntriesJob.new(person.id))  
    end    
    
    respond_to do |format|
      flash[:notice] = total_entries.to_s + ' feed entries of the ' + @project.persons.count.to_s + ' people on this project will be updated. Please give it some time to finish.'
      format.js do
        render :update do |page|          
          page.reload
        end
      end
    end
    
  end
  
  def update_all_project_people
    @project = Project.find(params[:id])    
        
    @project.persons.each do |person|
      Delayed::Job.enqueue(UpdatePersonJob.new(person.twitter_id))  
    end        
    
    respond_to do |format|
      flash[:notice] = @project.persons.count.to_s + ' people on this project will be updated. Please give it some time to finish.'
      format.js do
        render :update do |page|          
          page.reload
        end
      end
    end
  end

  
  def csv_import
     @project = Project.find(params[:id])
     @parsed_file=CSV::Reader.parse(params[:dump][:file])
     maxfriends = params[:max_friends]
     
     n=0
     @parsed_file.each  do |row|
        username = URI.parse(row[0].to_s).path.reverse.chop.reverse
        begin
          category = row[1]
        rescue
          category = ""
        end
        logger.info "CSV Import: Importing person #{username} and category #{category}"
        Delayed::Job.enqueue(CollectPersonJob.new(username,@project.id,maxfriends,category))  
        n=n+1          
     end
     respond_to do |format|
      flash[:notice]="CSV Import Successful,  #{n} new Persons will with less than #{maxfriends} friends be added to data base"
      format.html { redirect_to projects_path }
     end           
  end
  
  
  def csv_feed_import
     @project = Project.find(params[:id])
     @parsed_file=CSV::Reader.parse(params[:dump][:file])
     
     n=0
     @parsed_file.each  do |row|
        tweet_id = row.first.scan(/\d+/).last
        logger.info "CSV Import: Importing feed entry " + tweet_id.to_s
        Delayed::Job.enqueue(CollectFeedEntryAndRetweetsJob.new(@project.id,tweet_id))        
        n=n+1          
     end     
     respond_to do |format|
      flash[:notice]="CSV Import Successful,  #{n} new FeedEntries and retweets will be added to data base"
      format.html { redirect_to projects_path }
     end           
  end
  
  #exports Relationships between people to UCI_NET
  def generate_csv
    @project = Project.find(params[:id])
    
    content_type = if request.user_agent =~ /windows/i
                 ' application/vnd.ms-excel '
               else
                 ' text/csv '
               end
    
    project_net = @project.find_all_connections(friend = true, follower = false)   
    
    CSV::Writer.generate(output = "") do |csv|
      csv << ["DL n=" + @project.persons.count.to_s ]
      csv << ["format = edgelist1"]
      csv << ["labels embedded:"]
      csv << ["data:"]
      project_net.each do |entry|
        csv << [entry[0], entry[1], "1"]
      end
    end
    send_data(output,
            :type => content_type,
            :filename => @project.name.to_s + "_SNA.csv")
  end
  
  
  def generate_retweet_net
   @project = Project.find(params[:id])
    
    content_type = if request.user_agent =~ /windows/i
                 ' application/vnd.ms-excel '
               else
                 ' text/csv '
               end
    project_net = @project.find_all_retweet_connections(friend = true, follower = false) 
        
    CSV::Writer.generate(output = "") do |csv|
      csv << ["DL n=" + @project.persons.count.to_s ]
      csv << ["format = edgelist1"]
      csv << ["labels embedded:"]
      csv << ["data:"]
      project_net.each do |entry|
        csv << [entry[0], entry[1], entry[2]]
      end
    end
    send_data(output,
            :type => content_type,
            :filename => @project.name.to_s + "retweet_SNA.csv")
  end
  
  def generate_valued_csv
    @project = Project.find(params[:id])
    
    content_type = if request.user_agent =~ /windows/i
                 ' application/vnd.ms-excel '
               else
                 ' text/csv '
               end
    project_net = @project.find_all_valued_connections(friend = true, follower = false) 
        
    CSV::Writer.generate(output = "") do |csv|
      csv << ["DL n=" + @project.persons.count.to_s ]
      csv << ["format = edgelist1"]
      csv << ["labels embedded:"]
      csv << ["data:"]
      project_net.each do |entry|
        csv << [entry[0], entry[1], entry[2]]
      end
    end
    send_data(output,
            :type => content_type,
            :filename => @project.name.to_s + "_SNA.csv")
  end
  
  def generate_gephi
    @project = Project.find(params[:id])
    project_net = @project.find_all_id_connections(friend = true, follower = false)
    
    #read in filter list if exists
    twitter_ids = []
    begin
      csv_file = @project.name.downcase + ".csv"
      CSV::Reader.parse(File.open(csv_file, 'rb')) do |row  |
        result = URI.parse(row.to_s).path.reverse.chop.reverse      
        twitter_ids <<  result.downcase
        puts result.downcase
      end
    rescue
      puts "No attributelist found"  
    end
    
    CSV::Writer.generate(output = "") do |csv|
      csv << ["<?xml version='1.0' encoding='UTF-8'?>"]
      csv << ["<gexf xmlns='http://www.gexf.net/1.1draft' version='1.1'>"]
      csv << ["<meta lastmodifieddate='"+ Time.now.strftime("%Y-%d-%m") + "'>"]
      csv << ["<creator>plotti@gmx.net</creator>"]
      csv << ["<default>yellow</default>"]
      csv << ["<description>" + @project.name + "</description>"]
      csv << ["</meta>"]
      csv << ["<graph mode='static' defaultedgetype='directed'>"]
      csv << ["<attributes class='node'>"]
      csv << ["<attribute id='0' title='role' type='string'/>"]
      csv << ["</attributes>"]
      csv << ["<nodes>"]
      @project.persons.each do |person|
        csv << ["<node id='"+ person.twitter_id.to_s + "' label='" + person.username.downcase + "' >"]
        csv << ["<attvalues>"]
        if twitter_ids.include?(person.username.downcase)
          csv << ["<attvalue for='0' value='listed'/>"]
        else
          csv << ["<attvalue for='0' value='not_listed'/>"]
        end
        csv << ["</attvalues>"]
        csv << ["</node>"]
      end
      csv << ["</nodes>"]
      csv << ["<edges>"]
      i = 1
      project_net.each do |entry|
        csv<< ["<edge id='" + i.to_s + "' source='" + entry[0].to_s + "' target='" + entry[1].to_s + "' />"]
        i += 1
      end
      csv << ["</edges>"]
      csv << ["</graph>"]
      csv << ["</gexf>"]
    end
    send_data(output,
          :filename => @project.name.to_s + "_SNA.gexf")
  end
  
  def generate_stats
    @project = Project.find(params[:id])
    
    content_type = if request.user_agent =~ /windows/i
             ' application/vnd.ms-excel '
           else
             ' text/csv '
           end
    
    CSV::Writer.generate(output = "") do |csv|
      csv << ["Person", "Twitter_Username", "Friends", "Followers", "Messages", "Acc Created", "Last Activity", "Description", "Location", "Time Offset"]
      @project.persons.each do |person|
        csv << [person.name, person.username, person.friends_count, person.followers_count, person.statuses_count, person.acc_created_at, person.last_activity, person.bio, person.location, person.time_offset]
      end
    end
    send_data(output,
            :type => content_type,
            :filename => @project.name.to_s + "_stats" + ".csv")
    
  end
  
  def generate_retweet_stats
    @project = Project.find(params[:id])
    @project_person_names = @project.persons.collect{|p| p.username}    
    content_type = if request.user_agent =~ /windows/i
             ' application/vnd.ms-excel '
           else
             ' text/csv '
    end
    
    CSV::Writer.generate(output = "") do |csv|
      csv << ["*node data"]
      csv << ["ID", "Total Tweet Count", "Own Retweeted Count", "Network Retweet Count"]
      @project.persons.each do |person|
        own_retweeted_count = 0
        network_retweet_count = 0
        person.feed_entries.each do |entry|
          own_retweeted_count += entry.retweet_ids.count
          entry.retweet_ids.each do |retweet|
            if @project_person_names.include?(retweet[:person])
              network_retweet_count += 1
            end
          end
        end
      csv << [person.username, person.feed_entries.count, own_retweeted_count, network_retweet_count]
      end      
    end
    send_data(output,
        :type => content_type,
        :filename => @project.name.to_s + "_retweet_stats" + ".csv")
    
  end
  
    #exports Relationships between people to UCI_NET
  def generate_igraph
    @project = Project.find(params[:id])
    
    content_type = if request.user_agent =~ /windows/i
                 ' application/vnd.ms-excel '
               else
                 ' text/csv '
               end
    
    project_net = Follower.all(:conditions => ["project_id = ?", @project.id])    
    
    CSV::Writer.generate(output = "") do |csv|
      project_net.each do |entry|
        follower_id = Person.find_by_username(entry.person).id
        followed_by_id = Person.find_by_username(entry.followed_by_person).id
        csv << [follower_id, followed_by_id]
      end
    end
    send_data(output,
            :type => content_type,
            :filename => @project.name.to_s  + ".txt")
  end
  
  def generate_twitter_links
        @project = Project.find(params[:id])
    content_type = if request.user_agent =~ /windows/i
             ' application/vnd.ms-excel '
           else
             ' text/csv '
           end
    
    CSV::Writer.generate(output = "") do |csv|      
      @project.persons.each do |person|
        csv << ["http://twitter.com/" + person.username]
      end
    end
    send_data(output,
            :type => content_type,
            :filename => @project.name.to_s + "_twitter_links" + ".csv")
  end
  
  def generate_twitter_messages
    @project = Project.find(params[:id])
    content_type = if request.user_agent =~ /windows/i
             ' application/vnd.ms-excel '
           else
             ' text/csv '
    end
     CSV::Writer.generate(output = "") do |csv|      
      csv << ["ID","Text", "Author", "url", "published at", "in reply to status id", "retweet of the id"]
      @project.persons.each do |person|
        person.feed_entries.each do |entry|
          text = entry.text
          text.gsub!(/[\n]+/, "");
          csv << [entry.id, '"' + text + '"', entry.author, entry.url, entry.published_at, entry.reply_to, entry.retweet_ids.join(",")]  
        end        
      end
    end
    send_data(output,
            :type => content_type,
            :filename => @project.name.to_s + "_twitter_messages" + ".csv")
  end
  
  def export_valued_to_uci_net
    render :update do |page|
      page.redirect_to :action => "generate_valued_csv", :id => params[:id]
    end
  end
  
  def export_to_uci_net
    render :update do |page|
      page.redirect_to :action => "generate_csv", :id => params[:id]
    end
  end
  
  def export_to_gephi
    render :update do |page|
      page.redirect_to :action => "generate_gephi", :id => params[:id]
    end
  end
  
  def export_person_stats
    render :update do |page|
      page.redirect_to :action => "generate_stats", :id => params[:id]
    end
  end
  
    
  def export_twitter_links
    render :update do |page|
      page.redirect_to :action => "generate_twitter_links", :id => params[:id]
    end
  end
  
  def export_twitter_messages
    render :update do |page|
      page.redirect_to :action => "generate_twitter_messages", :id => params[:id]
    end
  end
  
  def export_retweet_stats
    render :update do |page|
      page.redirect_to :action => "generate_retweet_stats", :id => params[:id]
    end
  end
  
  def export_retweet_net_to_uci_net
    render :update do |page|
      page.redirect_to :action => "generate_retweet_net", :id => params[:id]
    end
  end
  
  
  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml  { head :ok }
    end
  end
end
