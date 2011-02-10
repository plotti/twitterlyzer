class SearchResultsController < ApplicationController
  layout 'default'
  
  def index    
    @search = Search.find(params[:search_id])
    @project = Project.find(@search.project_id)
    @search_results = @search.search_results
        
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @search_result }
    end
  end
  
  def show_feeds
    @search = Search.find(params[:search_id])
    @project = Project.find(params[:project_id])
    @search_results = @search.search_results
    
    @feed_entries = []
    @search_results.each do |result|
      if result.feed_entry != nil
        @feed_entries << result.feed_entry
      end
    end

    respond_to do |format|
      format.html
      format.xml  { render :xml => @feed_entries }
    end
  end
  
  def show_persons
    @search = Search.find(params[:search_id])
    @project = Project.find(params[:project_id])
    @search_results = @search.search_results
    
    @persons = []
    @search_results.each do |result|
      @persons << result.person 
    end
    @persons.uniq!
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @feed_entries }
    end
  end
  
  def show
    @search_result = SearchResult.find(params[:id])    

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @search_result }
    end
  end
  
end