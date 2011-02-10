class SearchesController < ApplicationController
  layout 'default'
  
  def new
    @search = Search.new
    @project = Project.find(params[:project_id])
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @search.project_id}
    end
  end
  
  def index    
    @project = Project.find(params[:project_id])
    @searches = @project.searches
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @searches }
    end
  end
    
  def show
    @search = Search.find(params[:id])    
    @project = Project.find(@search.project_id)
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @search }
    end
  end
  
  def create    
    @search = Search.new(:search_query => params[:search][:search_query], :project_id => params[:project_id])    
    
    respond_to do |format|
      if @search.save
        #collect Search results.
        @search.collect_search_results    
        flash[:notice] = 'Search was successfully created. Search results will be collected.'
        format.html { redirect_to project_searches_path}
        format.xml  { render :xml => @search, :status => :created, :location => project_search_path }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @search.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def collect_persons_and_feeds    
    search = Search.find(params[:id])    
    search.search_results.each do |search_result|
      Delayed::Job.enqueue(CollectPersonsAndFeedsJob.new(search_result.id, search.project_id))  
      #SearchResult.collect(search_result.id, search.project_id)
    end
    
    respond_to do |format|
      flash[:notice] = "Persons and Feeds of this search result will be collected. Give it some time to finish."
      format.js do
        render :update do |page|          
          page.reload
        end
      end 
    end
  end
  
  def destroy
    @search = Search.find(params[:id])
    @search.destroy

    respond_to do |format|
      flash[:notice] = 'Search was deleted.'
      format.html { redirect_to(project_searches_path) }
      format.xml  { head :ok }
    end
  end
  
end