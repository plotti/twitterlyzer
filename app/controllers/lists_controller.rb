class ListsController < ApplicationController
  require 'csv'
  layout 'default'
  
  def index
    @project = Project.find(params[:project_id])
    @lists = @project.lists.paginate :page => params[:page]
        
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lists }
    end
  end
  
    
  def collect_list_memberships
     @project = Project.find(params[:id])
     @project.persons.each  do |person|
      Delayed::Job.enqueue(CollectListMembershipsJob.new(person.id, @project.id))                
     end     
     respond_to do |format|
      flash[:notice]="Lists based on Memberships for the project people will added to the project"
      format.html { redirect_to projects_path }
     end           
  end
  
  def collect_list_members
    @project = Project.find(params[:id])
    @lists = @project.lists
    @lists.each do |list|
      Delayed::Job.enqueue(CollectListMembersJob.new(list.id))      
    end
    respond_to do |format|
      flash[:notice]="List members will added to the lists"
      format.html { redirect_to project_lists_path(@project) }
     end   
  end
  
end
