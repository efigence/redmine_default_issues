class DefaultIssueRelationsController < ApplicationController
  unloadable
  
  before_filter :find_default_issue, :find_project, :authorize, :only => [:index, :create]
  before_filter :find_relation, :except => [:index, :create]
  
  accept_api_auth :index, :show, :create, :destroy

  def index
    @relations = @default_issue.relations

    respond_to do |format|
      format.html { render :nothing => true }
      format.api
    end
  end

  def show
    raise Unauthorized unless @relation.visible?

    respond_to do |format|
      format.html { render :nothing => true }
      format.api
    end
  end


  def create
    @relation = DefaultIssueRelation.new(params[:relation])
    @relation.default_issue_from = @default_issue
    if params[:relation] && m = params[:relation][:default_issue_to_id].to_s.strip.match(/^#?(\d+)$/)
      @relation.default_issue_to = DefaultIssue.visible.find_by_id(m[1].to_i)
    end
    saved = @relation.save

    respond_to do |format|
      format.html { redirect_to project_default_issue_path(@default_issue) }
      format.js {render js: %(window.location.href='#{project_default_issue_path(@project, @default_issue)}')}
      format.api {
        if saved
          render :action => 'index',  :status => :created, :location => s(@project, @default_issue)
        else
          render_validation_errors(@relation)
        end
      }
    end
  end

  def destroy
    #with this doesn't work...
    #raise Unauthorized unless @relation.deletable? 
    @relation.destroy

    respond_to do |format|
      format.html { redirect_to project_default_issue_path(@relation.issue_from) }
      format.js
      format.api  { render_api_ok }
    end
  end

private
  def find_default_issue
    @default_issue = @object = DefaultIssue.find(params[:default_issue_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_relation
    @relation = DefaultIssueRelation.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_project
    @project = Project.find(params[:project_id])
  end
end