class DefaultIssue < ActiveRecord::Base
  unloadable


  validates :subject, :presence => true
  validates :status_id, :presence => true
  validates :author_id, :presence => true
  validates :priority_id, :presence=> true
  validates :tracker_id, :presence => true
  validates :project_id, :presence => true
  validates :description, :presence => true
  validates :estimated_hours, :presence => true

  acts_as_nested_set :scope => "root_id", :dependent => :destroy
  
    def to_issue(user)
        i = Issue.new
        i.author_id = author_id
        i.project_id = project_id
        i.subject = subject
        i.description = description
        i.tracker_id = tracker_id
        i.priority_id = priority_id
        i.estimated_hours = estimated_hours
        i.assigned_to = user
        i
    end



end
