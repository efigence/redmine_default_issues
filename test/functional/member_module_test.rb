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
        assert issue, 'issue misssing'
        assert_default_issue_with_issue(di, issue)  
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
end