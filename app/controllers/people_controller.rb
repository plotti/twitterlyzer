class PeopleController < ApplicationController
  layout 'default'

  # GET /people
  # GET /people.xml
  
  def index    
    @project = Project.find(params[:project_id])
    @persons = @project.persons
    
    @persons_by_country = Hash.new    
    @project.persons.count(:group => 'time_offset').each do |key,value|
      @persons_by_country[CITIES_MAP[key]] = value
    end
    
    @persons_by_followers = @project.persons.count(:order => 'followers_count ASC', :group => 'ROUND(LN(followers_count),0)')
    @persons_by_friends = @project.persons.count(:order => 'friends_count ASC', :group => 'ROUND(LN(friends_count),0)')
    @persons_by_tweets  = @project.persons.count(:order => 'statuses_count ASC', :group => 'ROUND(LN(statuses_count),0)')
    @persons_by_activity = @project.persons.count(:order => 'last_activity DESC', :group => "DATE(last_activity)")
    @persons_by_join = @project.persons.count(:order => 'acc_created_at DESC', :group => "DATE(acc_created_at)")
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @people }
    end
  end
  
  def show_all
    @project = Project.find(params[:project_id])
    @persons = @project.persons.paginate :page => params[:page], :order => 'updated_at DESC'
    
    respond_to do |format|
      format.html
      format.xml {render :xml => @people }
    end
  end
  
  #Lists all Friends of a given person
  def friends
    @person = Person.find(params[:id])  
    @project = Project.find(params[:project_id])    
    @persons = @person.get_all_friends
        
    respond_to do |format|
      format.html # friends.html.erb
      format.xml  { render :xml => @persons }
    end
        
  end
  
  # Lists all followers of a given Person
  def followers
    @person = Person.find(params[:id])      
    @project = Project.find(params[:project_id])
    @persons = @person.get_all_followers
    
    respond_to do |format|
      format.html # followers.html.erb
      format.xml  { render :xml => @persons }
    end
        
  end
  
  # GET /people/1
  # GET /people/1.xml
  def show
    @person = Person.find(params[:id])
    @project = Project.find(params[:project_id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/new
  # GET /people/new.xml
  def new
    @person = Person.new
    @project = Project.find(params[:project_id])
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
  end

  def collect_all_friends
    person = Person.find(params[:id])
    project = Project.find(params[:project_id])
    
    #Fast Version
    person.friends_ids.each do |friend_id|
      Delayed::Job.enqueue(CollectPersonJob.new(friend_id,project.id,100000))  
    end
    
    #Standard version
    #Delayed::Job.enqueue(CollectPersonAndFriendsJob.new(person.twitter_id,project.id,100000))  
    
    respond_to do |format|
      format.js do
        render :update do |page|
          flash[:notice] = 'Please wait.... Over ' + person.friends_count.to_s + ' friends will be collected.'
          page.reload
        end
      end
    end
  end
  
  def collect_all_followers
    person = Person.find(params[:id])
    project = Project.find(params[:project_id])
    
    #Fast Version
    person.follower_ids.each do |follower_id|
      Delayed::Job.enqueue(CollectPersonJob.new(follower_id,project.id,100000))  
    end
    
    #Standard Version
    #Delayed::Job.enqueue(CollectPersonAndFollowersJob.new(person.twitter_id,project.id,100000))  
    
    respond_to do |format|
      format.js do
        render :update do |page|
          flash[:notice] = 'Please wait ... Over ' + person.followers_count.to_s + '  followers will be collected.'
          page.reload
        end
      end
    end    
  end
  
  # Collects egonet based on a group of people
  def collect_two_step_egonet
    person = Person.find(params[:id])
    project = Project.find(params[:project_id])    
    maxfriends = params[:max_friends]
  
    #Collect Friends of person
    person.follower_ids.each do |friend_id|
      Delayed::Job.enqueue(CollectPersonAndFriendsJob.new(friend_id,project.id,maxfriends))  
    end
    
    respond_to do |format|
      flash[:notice] = 'A two step with friendscount smaller than ' + maxfriends.to_s + ' will be collected. This might take a long time.'
      format.js do
        render :update do |page|          
          page.reload
        end
      end
    end    
  end
  
    
  # Collects egonet based on a group of people
  def collect_project_persons_egonets
    project = Project.find(params[:project_id]) 
    persons = project.persons
    maxfriends = params[:max_friends]
    
    #Collect Friends of person
    persons.each do |person|
      person.friends_ids.each do |friend_id|       
        Delayed::Job.enqueue(CollectPersonJob.new(friend_id,project.id,maxfriends))
      end
    end
    
    respond_to do |format|
      flash[:notice] = 'A two step with friendscount smaller than ' + maxfriends.to_s + ' will be collected. This might take a long time.'
      format.js do
        render :update do |page|          
          page.reload
        end
      end
    end    
  end
  
  
  # POST /people
  # POST /people.xml
  def create
    @project = Project.find(params[:project_id])
    username = params[:person][:username]
    collect_followers = params[:collect_followers]
    collect_friends = params[:collect_friends]
    
    puts "Params collect_friends:#{collect_friends} collect_followers:#{collect_followers}"
    @person = Person.collect_person(username,@project,1000000, collect_friends, collect_followers)         
    
    respond_to do |format|            
      if @person != nil
        flash[:notice] = 'Person was successfully created.'
        format.html { redirect_to(project_person_path(@project,@person)) }
        format.xml  { render :xml => @person, :status => :created, :location => @person }
      else
        @person = Person.new
        flash[:notice] = 'Username not found.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end      
    end
    
  end

  # PUT /people/1
  # PUT /people/1.xml
  def update
    @project = Project.find(params[:project_id])
    @person = Person.find(params[:id])

    respond_to do |format|
      if @person.update_attributes(params[:person])
        flash[:notice] = 'Person was successfully updated.'
        format.html { redirect_to(@person) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @project = Project.find(params[:project_id])
    @person = Person.find(params[:id])
    @project.persons.delete(@person)

    respond_to do |format|
      format.html { redirect_to(project_people_path(@project)) }
      format.xml  { head :ok }
    end
  end
    
end
