class AddRoleIdToDefaultIssue < ActiveRecord::Migration
  def change
    add_column :default_issues, :role_id, :integer
    add_index "default_issues", ["role_id"], :name => "index_default_issues_on_role_id"
  end
end
