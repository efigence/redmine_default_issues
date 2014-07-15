class DefaultIssue < ActiveRecord::Base
  unloadable
  
  attr_accessible :subject, :status_id, :author_id, :priority_id, :role_id,
                  :tracker_id, :project_id, :description, :estimated_hours, 
                  :parent_id, :root_id, :start_date, :due_date

  validates :due_date, :date => true
  validates :start_date, :date => true
  validates :subject, :presence => true
  validates :role_id, :presence => true
  validates :status_id, :presence => true
  validates :author_id, :presence => true
  validates :priority_id, :presence=> true
  validates :tracker_id, :presence => true
  validates :project_id, :presence => true
  validates :description, :presence => true
  validates :estimated_hours, :presence => true, :numericality => true
  validate :validate_default_issue_estimated_hours

  acts_as_nested_set :scope => "root_id", :dependent => :destroy

  belongs_to :priority, :class_name => 'IssuePriority', :foreign_key => 'priority_id'

  has_and_belongs_to_many :users, :join_table => "#{table_name_prefix}users_default_issues#{table_name_suffix}", :foreign_key => "default_issue_id"
  
  after_save :recalculate_parent
  
  has_many :relations_from, :class_name => 'DefaultIssueRelation', :foreign_key => 'default_issue_from_id', :dependent => :delete_all
  has_many :relations_to, :class_name => 'DefaultIssueRelation', :foreign_key => 'default_issue_to_id', :dependent => :delete_all
  
  def validate_default_issue_estimated_hours
    if due_date != nil
      if due_date < start_date
        errors.add :due_date, :greater_than_start_date
      end
    end
  end

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

  def relations
    @relations ||= DefaultIssueRelation::Relations.new(self, (relations_from + relations_to).sort)
  end

  def self.load_relations(default_issues)
    if default_issues.any?
      relations = DefaultIssueRelation.where("default_issue_from_id IN (:ids) OR default_issue_to_id IN (:ids)", :ids => default_issues.map(&:id)).all
      default_issues.each do |default_issue|
        default_issue.instance_variable_set "@relations", relations.select {|r| r.default_issue_from_id == default_issue.id || r.default_issue_to_id == default_issue.id}
      end
    end
  end

   #this is for auto-completes--------------IN PROGRESS!!!
  belongs_to :project

  scope :visible, lambda {|*args|
    includes(:project).where(DefaultIssue.visible_condition(args.shift || User.current, *args))
  }
  
  def self.visible_condition(user, options={})
    Project.allowed_to_condition(user, :view_default_issue, options) do |role, user|
      if user.logged?
        case role.issues_visibility
        when 'all'
          nil
        when 'default'
          user_ids = [user.id] + user.groups.map(&:id).compact
          "(#{table_name}.is_private = #{connection.quoted_false} OR #{table_name}.author_id = #{user.id} OR #{table_name}.assigned_to_id IN (#{user_ids.join(',')}))"
        when 'own'
          user_ids = [user.id] + user.groups.map(&:id).compact
          "(#{table_name}.author_id = #{user.id} OR #{table_name}.assigned_to_id IN (#{user_ids.join(',')}))"
        else
          '1=0'
        end
      else
        "(#{table_name}.is_private = #{connection.quoted_false})"
      end
    end
  end
  
  def visible?(usr=nil)
    (usr || User.current).allowed_to?(:view_default_issue, self.project) do |role, user|
      if user.logged?
        case role.issues_visibility
        when 'all'
          true
        when 'default'
          !self.is_private? || (self.author == user || user.is_or_belongs_to?(assigned_to))
        when 'own'
          self.author == user || user.is_or_belongs_to?(assigned_to)
        else
          false
        end
      else
        !self.is_private?
      end
    end
  end
  #--------------------------------------------

  def self.load_visible_relations(default_issues, user=User.current)
    if default_issues.any?
      default_issue_ids = default_issues.map(&:id)
      # Relations with default_issue_from in given default_issues and visible default_issue_to
      relations_from = DefaultIssueRelation.includes(:default_issue_to => [:status, :project]).where(visible_condition(user)).where(:default_issue_from_id => default_issue_ids).all
      # Relations with default_issue_to in given default_issues and visible default_issue_from
      relations_to = DefaultIssueRelation.includes(:default_issue_from => [:status, :project]).where(visible_condition(user)).where(:default_issue_to_id => default_issue_ids).all

      default_issues.each do |default_issue|
        relations =
          relations_from.select {|relation| relation.default_issue_from_id == default_issue.id} +
          relations_to.select {|relation| relation.default_issue_to_id == default_issue.id}

        default_issue.instance_variable_set "@relations", DefaultIssueRelation::Relations.new(default_issue, relations.sort)
      end
    end
  end

  def find_relation(relation_id)
    DefaultIssueRelation.where("default_issue_to_id = ? OR default_issue_from_id = ?", id, id).find(relation_id)
  end

  def all_dependent_default_issues(except=[])
    # The found dependencies
    dependencies = []

    # The visited flag for every node (default_issue) used by the breadth first search
    eNOT_DISCOVERED         = 0       # The default_issue is "new" to the algorithm, it has not seen it before.

    ePROCESS_ALL            = 1       # The default_issue is added to the queue. Process both children and relations of
                                      # the default_issue when it is processed.

    ePROCESS_RELATIONS_ONLY = 2       # The default_issue was added to the queue and will be output as dependent issue,
                                      # but its children will not be added to the queue when it is processed.

    eRELATIONS_PROCESSED    = 3       # The related default_issues, the parent default_issue and the default_issue itself have been added to
                                      # the queue, but its children have not been added.

    ePROCESS_CHILDREN_ONLY  = 4       # The relations and the parent of the default_issue have been added to the queue, but
                                      # the children still need to be processed.

    eALL_PROCESSED          = 5       # The default_issue and all its children, its parent and its related default_issues have been
                                      # added as dependent default_issues. It needs no further processing.

    default_issue_status = Hash.new(eNOT_DISCOVERED)
    # The queue
    queue = []

    # Initialize the bfs, add start node (self) to the queue
    queue << self
    default_issue_status[self] = ePROCESS_ALL

    while (!queue.empty?) do
      current_default_issue = queue.shift
      current_default_issue_status = default_issue_status[current_default_issue]
      dependencies << current_default_issue

      # Add parent to queue, if not already in it.
      parent = current_default_issue.parent
      parent_status = default_issue_status[parent]

      if parent && (parent_status == eNOT_DISCOVERED) && !except.include?(parent)
        queue << parent
        default_issue_status[parent] = ePROCESS_RELATIONS_ONLY
      end

      # Add children to queue, but only if they are not already in it and
      # the children of the current node need to be processed.
      if (current_default_issue_status == ePROCESS_CHILDREN_ONLY || current_default_issue_status == ePROCESS_ALL)
        current_default_issue.children.each do |child|
          next if except.include?(child)

          if (default_issue_status[child] == eNOT_DISCOVERED)
            queue << child
            default_issue_status[child] = ePROCESS_ALL
          elsif (default_issue_status[child] == eRELATIONS_PROCESSED)
            queue << child
            default_issue_status[child] = ePROCESS_CHILDREN_ONLY
          elsif (default_issue_status[child] == ePROCESS_RELATIONS_ONLY)
            queue << child
            default_issue_status[child] = ePROCESS_ALL
          end
        end
      end

      # Add related issues to the queue, if they are not already in it.
      current_default_issue.relations_from.map(&:default_issue_to).each do |related_default_issue|
        next if except.include?(related_default_issue)

        if (default_issue_status[related_default_issue] == eNOT_DISCOVERED)
          queue << related_default_issue
          default_issue_status[related_default_issue] = ePROCESS_ALL
        elsif (default_issue_status[related_default_issue] == eRELATIONS_PROCESSED)
          queue << related_default_issue
          default_issue_status[related_default_issue] = ePROCESS_CHILDREN_ONLY
        elsif (default_issue_status[related_default_issue] == ePROCESS_RELATIONS_ONLY)
          queue << related_default_issue
          default_issue_status[related_default_issue] = ePROCESS_ALL
        end
      end

      # Set new status for current issue
      if (current_default_issue_status == ePROCESS_ALL) || (current_default_issue_status == ePROCESS_CHILDREN_ONLY)
        default_issue_status[current_default_issue] = eALL_PROCESSED
      elsif (current_default_issue_status == ePROCESS_RELATIONS_ONLY)
        default_issue_status[current_default_issue] = eRELATIONS_PROCESSED
      end
    end # while

    # Remove the issues from the "except" parameter from the result array
    dependencies -= except
    dependencies.delete(self)

    dependencies
  end

  # Returns an array of issues that duplicate this one
  def duplicates
    relations_to.select {|r| r.relation_type == DefaultIssueRelation::TYPE_DUPLICATES}.collect {|r| r.default_issue_from}
  end
  
  def soonest_start(reload=false)
    @soonest_start = nil if reload
    @soonest_start ||= (
        relations_to(reload).collect{|relation| relation.successor_soonest_start} +
        [(@parent_issue || parent).try(:soonest_start)]
      ).compact.max
  end
end
