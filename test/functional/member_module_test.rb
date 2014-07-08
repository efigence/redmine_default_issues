require File.expand_path('../../test_helper', __FILE__)
require File.expand_path('../../../lib/redmine_default_issues/patches/member_patch', __FILE__)

class MemberModuleTest < ActiveSupport::TestCase
  self.fixture_path = File.join(File.dirname(__FILE__), '../fixtures')

  fixtures :roles, :trackers, :projects_trackers, :enumerations, :projects, :users, :issue_statuses, :default_issues


  def assert_default_issue_with_issue(default_issue, issue)
    [:subject, :description, :tracker_id, :status_id, :author_id, :priority_id, :project_id, :estimated_hours].each do |attr|
      assert_equal issue.send(attr), default_issue.send(attr), "mismatched #{attr}"
    end
    if default_issue.parent_id
      assert issue.parent_id, 'missing parent id'
      assert_default_issue_with_issue(issue.parent, default_issue.parent) 
    end
  end

  def array_to_object(collection)
    iss = {}
    collection.each do |issue|
      iss[issue.subject] = issue
    end
    iss
  end

  def assert_collection_of_default_issue_with_issue(default_issues, issues)
    iss = array_to_object(issues)
    diss = array_to_object(default_issues)

    diss.each do |subject, di|
      issue = iss[subject]
      assert issue, "issue misssing #{di.inspect}"
      assert_default_issue_with_issue(di, issue)  
    end
  end

  def create_child(root, parent, children_count = 0, max_level = 1, level = 0)
    level += 1

    child = DefaultIssue.new({
      created_on: 3.days.ago.to_s(:db),
      project_id: 1,
      updated_on: 1.day.ago.to_s(:db),
      priority_id: 4,
      subject: "You should generate your own ssh key first",
      category_id: 1,
      description: "Unable to print recipes",
      tracker_id: 2,
      author_id: 1,
      status_id: 1,
      start_date: 1.day.ago.to_date.to_s(:db),
      due_date: 10.day.from_now.to_date.to_s(:db),
      role_id: 1,
      assigned_to_id: 4,
      estimated_hours: 4
    })
    child.root_id = root.id if root
    child.parent_id = parent.id if parent
    child.save!

    child.subject = child.subject + " #{child.id}"
    child.description = child.description + " #{child.id}"
    child.save!

    unless root
      child.root_id = child.id
      child.save!
    end

    children_count.times do 
      create_child(root || child, child, children_count, max_level, level)
    end unless level > max_level
  end

  def create_fake_default_issues(roots_count = 1, children_count = 0, max_level = 1)
    DefaultIssue.transaction do
      roots_count.times do 
        create_child(nil, nil, children_count, max_level)
      end
    end
  end

  test "create tree default issue" do
    Issue.destroy_all
    DefaultIssue.destroy_all
    assert_difference 'Issue.where(project_id: 1, assigned_to_id: 4).count', +120 do
      di_count = DefaultIssue.count + 120
      create_fake_default_issues(3,3,3)
      di_count2 = DefaultIssue.count
      assert_equal di_count, di_count2, "create_fake_default_issues fail"

      roles = [1, 2]

      member = Member.new(:project_id => 1, :user_id => 4, :role_ids => roles)
      assert member.save
      member.reload

      roots = DefaultIssue.where(:project_id => 1, role_id: 1).roots
      assert_equal roots.count, 3

      issues = Issue.where(project_id: 1, assigned_to_id: 4).all
      default_issues = DefaultIssue.where(project_id: 1, :role_id => roles).all
      assert_collection_of_default_issue_with_issue(default_issues, issues)
    end
  end

  test "create, issue count should be increment" do
    assert_difference 'Issue.where(project_id: 1, assigned_to_id: 4).count', +1 do
      member = Member.new(:project_id => 1, :user_id => 4, :role_ids => [2])
      assert member.save
      member.reload

      assert_equal 1, member.roles.size
      assert_equal Role.find(2), member.roles.sort.first
    end
  end

  test "new_issue" do
    assert_difference 'Issue.where(project_id: 1, assigned_to_id: 4).count', +1 do
      member = Member.new(:project_id => 1, :user_id => 4, :role_ids => [2])
      assert member.save
      member.reload

      issues = Issue.where(project_id: 1, assigned_to_id: 4).all
      default_issues = DefaultIssue.where(project_id: 1, :role_id => [2] ).all
      assert_collection_of_default_issue_with_issue(default_issues, issues)
    end
  end

  test "Default Issue subissue's" do
    assert_difference 'Issue.where(project_id: 1, assigned_to_id: 4).count', +4 do
      member = Member.new(:project_id => 1, :user_id => 4, :role_ids => [1, 2])
      assert member.save
      member.reload
      roots = DefaultIssue.where(:project_id => 1, :role_id => 1, :parent_id => nil).all

      # diss is root?
      roots.each do |root|
        assert_equal root.root?, true
      end

      issues = Issue.where(project_id: 1, assigned_to_id: 4).all
      default_issues = DefaultIssue.where(project_id: 1, :role_id => [1, 2] ).all
      assert_collection_of_default_issue_with_issue(default_issues, issues)
    end
  end

  test "second time add same member to project" do
    assert_difference 'Issue.where(project_id: 1, assigned_to_id: 4).count', +4 do
      member = Member.new(:project_id => 1, :user_id => 4, :role_ids => [1, 2])
      assert member.save
      member.reload
      
      member.destroy
     
      member = Member.new(:project_id => 1, :user_id => 4, :role_ids => [1, 2])
      assert member.save
      member.reload
    end
  end
end