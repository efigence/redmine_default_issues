class DfAutoCompletesController < ApplicationController
  unloadable
  before_filter :find_project

  def default_issues
    @default_issues = []
    q = (params[:q] || params[:term]).to_s.strip
    if q.present?
      scope = (params[:scope] == "all" || @project.nil? ? DefaultIssue : @project.default_issues).visible
      if q.match(/\A#?(\d+)\z/)
        @default_issues << scope.find_by_id($1.to_i)
      end
      @default_issues += scope.where("LOWER(#{DefaultIssue.table_name}.subject) LIKE LOWER(?)", "%#{q}%").order("#{DefaultIssue.table_name}.id DESC").limit(10).all
      @default_issues.compact!
    end
    render :layout => false
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
