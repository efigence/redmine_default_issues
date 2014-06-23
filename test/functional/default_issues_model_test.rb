require File.expand_path('../../test_helper', __FILE__)

class DefaultIssuesTest < ActiveSupport::TestCase
  
  test "should not save default issues without author_id" do
 	d = DefaultIssue.new
 	assert !d.save, "Saved default issue without author_id"
  	assert !!d.errors[:author_id].any?, "author_id should be present"
  end

  test "should not save default issues without tracker_id" do
 	d = DefaultIssue.new
 	assert !d.save
 	assert !!d.errors[:tracker_id].any?, "tracker_id should be present"
  end

  test "should not save default issues without project_id" do
    d = DefaultIssue.new
    assert !d.save
    assert !!d.errors[:project_id].any?, "project_id should be present"
  end	

  test "should not save default issues without subject" do
  	d = DefaultIssue.new
  	assert !d.save 
  	assert !!d.errors[:subject].any?, "subject should be present"
  end

  test "should not save default issues without priority_id" do
  	d = DefaultIssue.new
  	assert !d.save 
  	assert !!d.errors[:priority_id].any?, "priority_id should be present"
  end

  test "should not save default issues without status_id" do
  	d = DefaultIssue.new
  	assert !d.save 
  	assert !!d.errors[:status_id].any?, "status_id should be present"
  end
  
  test "should not save default issues without estimated_hours" do
  	d = DefaultIssue.new
  	assert !d.save 
  	assert !!d.errors[:estimated_hours].any?, "estimated_hours should be present"
  end

  test "should not save default issues without description" do
  	d = DefaultIssue.new
  	assert !d.save 
  	assert !!d.errors[:description].any?, "description should be present"
  end



  #test "subissues" do
   # dissue = DefaultIssue.find(1)
   # dissue_child= Issue.where(project_id: dissue.project_id, root_id: dissue.id)
    #dissue_sub_child = Issue.where(project_id: dissue_child.project_id, root_id: dissue_child.id)
   # puts "1"
   #assert_equal Project.find(1), dissue_child.project_id 
    #parent = DefaultIssue.where(project_id: 1)
    #child = Issue.new(:project_id => 1, :tracker_id => 1, :author_id => 3,
   #                   :status_id => 1, :priority => 1,
    #                  :subject => 'parent_issue',
    #                  :description => 'IssueTest#parent_issue', :estimated_hours => '1:30', :root_id => parent.id)
    #assert_equal 
  #end
end
