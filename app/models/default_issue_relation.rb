class DefaultIssueRelation < ActiveRecord::Base
  unloadable
  class Relations < Array
    include Redmine::I18n

    def initialize(default_issue, *args)
      @default_issue = default_issue
      super(*args)
    end

    def to_s(*args)
      map {|relation| "#{l(relation.label_for(@default_issue))} ##{relation.other_default_issue(@default_issue).id}"}.join(', ')
    end
  end

  belongs_to :default_issue_from, :class_name => 'DefaultIssue', :foreign_key => 'default_issue_from_id'
  belongs_to :default_issue_to, :class_name => 'DefaultIssue', :foreign_key => 'default_issue_to_id'

  TYPE_RELATES      = "relates"
  TYPE_DUPLICATES   = "duplicates"
  TYPE_DUPLICATED   = "duplicated"
  TYPE_BLOCKS       = "blocks"
  TYPE_BLOCKED      = "blocked"
  TYPE_PRECEDES     = "precedes"
  TYPE_FOLLOWS      = "follows"
  TYPE_COPIED_TO    = "copied_to"
  TYPE_COPIED_FROM  = "copied_from"

  TYPES = {
    TYPE_RELATES =>     { :name => :label_relates_to, :sym_name => :label_relates_to,
                          :order => 1, :sym => TYPE_RELATES },
    TYPE_DUPLICATES =>  { :name => :label_duplicates, :sym_name => :label_duplicated_by,
                          :order => 2, :sym => TYPE_DUPLICATED },
    TYPE_DUPLICATED =>  { :name => :label_duplicated_by, :sym_name => :label_duplicates,
                          :order => 3, :sym => TYPE_DUPLICATES, :reverse => TYPE_DUPLICATES },
    TYPE_BLOCKS =>      { :name => :label_blocks, :sym_name => :label_blocked_by,
                          :order => 4, :sym => TYPE_BLOCKED },
    TYPE_BLOCKED =>     { :name => :label_blocked_by, :sym_name => :label_blocks,
                          :order => 5, :sym => TYPE_BLOCKS, :reverse => TYPE_BLOCKS },
    TYPE_PRECEDES =>    { :name => :label_precedes, :sym_name => :label_follows,
                          :order => 6, :sym => TYPE_FOLLOWS },
    TYPE_FOLLOWS =>     { :name => :label_follows, :sym_name => :label_precedes,
                          :order => 7, :sym => TYPE_PRECEDES, :reverse => TYPE_PRECEDES },
    TYPE_COPIED_TO =>   { :name => :label_copied_to, :sym_name => :label_copied_from,
                          :order => 8, :sym => TYPE_COPIED_FROM },
    TYPE_COPIED_FROM => { :name => :label_copied_from, :sym_name => :label_copied_to,
                          :order => 9, :sym => TYPE_COPIED_TO, :reverse => TYPE_COPIED_TO }
  }.freeze

  validates_presence_of :default_issue_from, :default_issue_to, :relation_type
  validates_inclusion_of :relation_type, :in => TYPES.keys
  validates_numericality_of :delay, :allow_nil => true
  validates_uniqueness_of :default_issue_to_id, :scope => :default_issue_from_id
  validate :validate_default_issue_relation

  attr_protected :default_issue_from_id, :default_issue_to_id
  before_save :handle_default_issue_order
  
  def to_issue_relation(issue_from, issue_to)
    iss_r = IssueRelation.where(issue_from_id: issue_from.id, issue_to_id: issue_to.id).first
    unless iss_r
      iss_r = IssueRelation.new
      iss_r.issue_from = issue_from
      iss_r.issue_to = issue_to
      iss_r.relation_type = relation_type
      iss_r.delay = delay
    end
    iss_r
  end

  def visible?(user=User.current)
    (default_issue_from.nil? || default_issue_from.visible?(user)) && 
    (default_issue_to.nil? || default_issue_to.visible?(user))
  end

  def deletable?(user=User.current)
    visible?(user) &&
      ((default_issue_from.nil? || user.allowed_to?(:manage_default_issue_relations, default_issue_from.project)) ||
        (default_issue_to.nil? || user.allowed_to?(:manage_default_issue_relations, default_issue_to.project)))
  end

  def initialize(attributes=nil, *args)
    super
    if new_record?
      if relation_type.blank?
        self.relation_type = DefaultIssueRelation::TYPE_RELATES
      end
    end
  end

  def validate_default_issue_relation
    if default_issue_from && default_issue_to
      errors.add :default_issue_to_id, :invalid if default_issue_from_id == default_issue_to_id
      unless default_issue_from.project_id == default_issue_to.project_id ||
                Setting.cross_project_issue_relations?
        errors.add :default_issue_to_id, :not_same_project
      end
      # detect circular dependencies depending wether the relation should be reversed
      if TYPES.has_key?(relation_type) && TYPES[relation_type][:reverse]
        errors.add :base, :circular_dependency if default_issue_from.all_dependent_default_issues.include? default_issue_to
      else
        errors.add :base, :circular_dependency if default_issue_to.all_dependent_default_issues.include? default_issue_from
      end
      if default_issue_from.is_descendant_of?(default_issue_to) || default_issue_from.is_ancestor_of?(default_issue_to)
        errors.add :default_issue_to_id, :cant_link_an_default_issue_with_a_descendant
      end
      if DefaultIssue.find(default_issue_from).role_id != DefaultIssue.find(default_issue_to).role_id
        errors.add :default_issue_to_id , :cant_create_relation_with_different_roles
      end
    end
  end

  def other_default_issue(default_issue)
    (self.default_issue_from_id == default_issue.id) ? default_issue_to : default_issue_from
  end

  # Returns the relation type for +default_issue+
  def relation_type_for(default_issue)
    if TYPES[relation_type]
      if self.default_issue_from_id == default_issue.id
        relation_type
      else
        TYPES[relation_type][:sym]
      end
    end
  end

  def label_for(default_issue)
    TYPES[relation_type] ?
        TYPES[relation_type][(self.default_issue_from_id == default_issue.id) ? :name : :sym_name] : :unknow
  end

  def css_classes_for(default_issue)
    "rel-#{relation_type_for(default_issue)}"
  end

  def handle_default_issue_order
    reverse_if_needed

    if TYPE_PRECEDES == relation_type
      self.delay ||= 0
    else
      self.delay = nil
    end
    set_default_issue_to_dates
  end

  def set_default_issue_to_dates
    soonest_start = self.successor_soonest_start
    if soonest_start && default_issue_to
      default_issue_to.reschedule_on!(soonest_start)
    end
  end

  def successor_soonest_start
    if (TYPE_PRECEDES == self.relation_type) && delay && default_issue_from &&
           (default_issue_from.start_date || default_issue_from.due_date)
      (default_issue_from.due_date || default_issue_from.start_date) + 1 + delay
    end
  end

  def <=>(relation)
    r = TYPES[self.relation_type][:order] <=> TYPES[relation.relation_type][:order]
    r == 0 ? id <=> relation.id : r
  end

  private
  
  #re-relation

  def reverse_if_needed
    if TYPES.has_key?(relation_type) && TYPES[relation_type][:reverse]
      default_issue_tmp = default_issue_to
      self.default_issue_to = default_issue_from
      self.default_issue_from = default_issue_tmp
      self.relation_type = TYPES[relation_type][:reverse]
    end
  end
end
