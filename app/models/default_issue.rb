class DefaultIssue < ActiveRecord::Base
  unloadable
  
  attr_accessible :subject, :status_id, :author_id, :priority_id, :role_id,
                  :tracker_id, :project_id, :description, :estimated_hours, 
                  :parent_id, :root_id, :start_date, :due_date

  validates :subject, :presence => true
  validates :status_id, :presence => true
  validates :author_id, :presence => true
  validates :priority_id, :presence=> true
  validates :tracker_id, :presence => true
  validates :project_id, :presence => true
  validates :description, :presence => true
  validates :estimated_hours, :presence => true

  acts_as_nested_set :scope => "root_id", :dependent => :destroy

  belongs_to :priority, :class_name => 'IssuePriority', :foreign_key => 'priority_id'
  has_and_belongs_to_many :users, :join_table => "#{table_name_prefix}users_default_issues#{table_name_suffix}", :foreign_key => "default_issue_id"
  after_save :recalculate_parent
  
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
      i.start_date = start_date
      i.due_date = due_date
      i
  end

  def recalculate_parent
    if parent_id
      recalculate_attributes_for(parent_id)
    end
  end

  def recalculate_attributes_for(default_issue_id)
    if default_issue_id && p = DefaultIssue.find_by_id(default_issue_id)
      # priority = highest priority of children
      if priority_position = p.children.joins(:priority).maximum("#{IssuePriority.table_name}.position")
        p.priority = IssuePriority.find_by_position(priority_position)
      end

      # start/due dates = lowest/highest dates of children
      p.start_date = p.children.minimum(:start_date)
      p.due_date = p.children.maximum(:due_date)
      if p.start_date && p.due_date && p.due_date < p.start_date
        p.start_date, p.due_date = p.due_date, p.start_date
      end

      # estimate = sum of leaves estimates
      p.estimated_hours = p.leaves.sum(:estimated_hours).to_f
      p.estimated_hours = nil if p.estimated_hours == 0.0

      # ancestors will be recursively updated
      p.save(:validate => false)
    end
  end
end
