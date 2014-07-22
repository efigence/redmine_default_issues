class DefaultIssuesController < ApplicationController
  unloadable
  
  helper :default_issue_relations
  before_filter :find_project, :authorize, :only => [:index, :new, :create, :show, :edit, :update]
   
  def index
    @default_issues = DefaultIssue.where(project_id:@project).order('role_id', 'root_id', 'parent_id')
  end

  def new
    @default_issue = DefaultIssue.new

    respond_to do |format|
      format.html
      format.json { render :json => @default_issue }
    end
  end

  def create
    @default_issue = DefaultIssue.new(params[:default_issue])
    
    respond_to do |format|
      if @default_issue.save
        format.html { redirect_to(project_default_issues_path, 
                      :notice => 'Default issue was successfully created.') }
        format.json { render :json => @default_issue, 
                      :status => :created, :location => @default_issue }
      else
        format.html { render :action => "new" }
        format.json { render :json => @default_issue.errors, 
                      :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @default_issue = DefaultIssue.find(params[:id])
    respond_to do |format|
      if @default_issue.update_attributes(params[:default_issue])
        format.html { redirect_to project_default_issues_path, notice: 'Default issue was successfully updated.' }
        format.json { render :show, status: :ok, location: @default_issue }
      else
        format.html { render :edit }
        format.json { render json: @default_issue.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def show
    @default_issue = DefaultIssue.find(params[:id])
    @relations = @default_issue.relations
  end

  def edit
    @default_issue = DefaultIssue.find(params[:id])
  end

  def destroy
    @default_issue = DefaultIssue.find(params[:id])
    @default_issue.destroy

    respond_to do |format|
      format.html { redirect_to project_default_issues_path, notice: 'Default issue was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private 
  
  def find_project
    @project = Project.find(params[:project_id])
  end
end
