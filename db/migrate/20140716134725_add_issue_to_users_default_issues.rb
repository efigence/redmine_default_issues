class AddIssueToUsersDefaultIssues < ActiveRecord::Migration
  def change
    add_column :users_default_issues, :issue_id, :integer, null: false
  end
end