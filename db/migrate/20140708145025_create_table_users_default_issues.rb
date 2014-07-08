class CreateTableUsersDefaultIssues < ActiveRecord::Migration
 def self.up
    create_table :users_default_issues, :id => false do |t|
      t.column :user_id, :integer, :null => false
      t.column :default_issue_id, :integer, :null => false
    end
    add_index "users_default_issues", ["user_id", "default_issue_id"], :unique => true, :name => "users_default_issues_ids"
  end

  def self.down
    drop_table :users_default_issues
  end
end