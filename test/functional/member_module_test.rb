require File.expand_path('../../test_helper', __FILE__)
require File.expand_path('../../../lib/redmine_default_issues/patches/member_patch', __FILE__)

class MemberModuleTest < ActiveSupport::TestCase
  self.fixture_path = File.join(File.dirname(__FILE__), '../fixtures')

  fixtures :roles, :trackers, :projects_trackers, :enumerations, :projects, :users, :issue_statuses, :default_issues

  test "create, issue count should be increment" do
    assert_difference 'Issue.where(project_id: 1, assigned_to_id: 4).count', +1 do
      member = Member.new(:project_id => 1, :user_id => 4, :role_ids => [1, 2])
      assert member.save
      member.reload

      assert_equal 2, member.roles.size
      assert_equal Role.find(1), member.roles.sort.first
    end
  end

  test "new_issue" do
    assert_difference 'Issue.where(project_id: 1, assigned_to_id: 4).count', +1 do
      member = Member.new(:project_id => 1, :user_id => 4, :role_ids => [1, 2])
      assert member.save
      member.reload

      issues = Issue.where(project_id: 1, assigned_to_id: 4).order('subject').all
      iss = {}
      issues.each do |issue|
        iss[issue.subject] = issue
      end

      default_issues = DefaultIssue.where(project_id: 1, :role_id => [1, 2] ).order('subject').all

      diss = {}
      default_issues.each do |dissue|
        diss[dissue.subject] = dissue
      end


      diss.each do |subject, di|
        issue = iss[subject]
        assert issue, 'issue misssing'

        [:subject, :description, :tracker_id, :status_id, :author_id, :priority_id, :project_id, :estimated_hours].each do |attr|
          assert_equal issue.send(attr), di.send(attr), "mismatched #{attr}"
        end        
      end
    end
  end

   # test "Added role to member, issue count should be increment" do
      #assert_difference 'Issue.where(project_id: 1, assigned_to_id: 4).count', +1 do
       # member = Member.new(:project_id => 1, :user_id => 4)
       # assert member.save
       # member.reload
        #member.roles << Role.find(1)
#
      #  puts "#{Issue.where(project_id: 1, assigned_to_id: 4).count}"
     # end
   # end


      #assert_difference 'Member.find(3).roles.count', +1 do
      #  member = Member.find(3).roles
      #  member << Role.find(2)
      #  assert_equal 3, Member.find(3).roles.count  



  #test "subissue" do
  #assert_difference 'Issue.where(root_id: 1)'  
  #  parent = Issue.where(project_id: 1, root_id: 1)
  #  child = Issue.where(root_id: parent.id)
    
  #  assert_equal child.root_id, parent.id
  #end
end