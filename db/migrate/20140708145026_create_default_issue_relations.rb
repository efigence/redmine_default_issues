class CreateDefaultIssueRelations < ActiveRecord::Migration
  def self.up
    create_table :default_issue_relations do |t|
      t.column :default_issue_from_id, :integer, :null => false
      t.column :default_issue_to_id, :integer, :null => false
      t.column :relation_type, :string, :default => "", :null => false
      t.column :delay, :integer
    end
    add_index "default_issue_relations", ["default_issue_from_id", "default_issue_to_id"], :name => "index_di_default_relations_on_di_from_id_and_di_to_id", :unique => true
    add_index "default_issue_relations", ["default_issue_from_id"], :name => "index_di_relations_on_di_from_id"
    add_index "default_issue_relations", ["default_issue_to_id"], :name => "index_di_relations_on_di_to_id"    
  end

  def self.down
    drop_table :default_issue_relations
  end
end
