class CreateDefaultIssues < ActiveRecord::Migration
  def change
    create_table "default_issues", :force => true do |t|
      t.integer  "tracker_id",                          :null => false
      t.integer  "project_id",                          :null => false
      t.string   "subject",          :default => "",    :null => false
      t.text     "description"
      t.date     "due_date"
      t.integer  "category_id"
      t.integer  "status_id",                           :null => false
      t.integer  "assigned_to_id"
      t.integer  "priority_id",                         :null => false
      t.integer  "fixed_version_id"
      t.integer  "author_id",                           :null => false
      t.integer  "lock_version",     :default => 0,     :null => false
      t.datetime "created_on"
      t.datetime "updated_on"
      t.date     "start_date"
      t.integer  "done_ratio",       :default => 0,     :null => false
      t.float    "estimated_hours"
      t.integer  "parent_id"
      t.integer  "root_id"
      t.integer  "lft"
      t.integer  "rgt"
      t.boolean  "is_private",       :default => false, :null => false
      t.datetime "closed_on"
    end

    add_index "default_issues", ["assigned_to_id"], :name => "index_default_issues_on_assigned_to_id"
    add_index "default_issues", ["author_id"], :name => "index_default_issues_on_author_id"
    add_index "default_issues", ["category_id"], :name => "index_default_issues_on_category_id"
    add_index "default_issues", ["created_on"], :name => "index_default_issues_on_created_on"
    add_index "default_issues", ["fixed_version_id"], :name => "index_default_issues_on_fixed_version_id"
    add_index "default_issues", ["priority_id"], :name => "index_default_issues_on_priority_id"
    add_index "default_issues", ["project_id"], :name => "default_issues_project_id"
    add_index "default_issues", ["root_id", "lft", "rgt"], :name => "index_default_issues_on_root_id_and_lft_and_rgt"
    add_index "default_issues", ["status_id"], :name => "index_default_issues_on_status_id"
    add_index "default_issues", ["tracker_id"], :name => "index_default_issues_on_tracker_id"
  end
end
=begin
mysql> describe default_issues;
+------------------+--------------+------+-----+---------+----------------+
| Field            | Type         | Null | Key | Default | Extra          |
+------------------+--------------+------+-----+---------+----------------+
| id               | int(11)      | NO   | PRI | NULL    | auto_increment |
| tracker_id       | int(11)      | NO   | MUL | NULL    |                |
| project_id       | int(11)      | NO   | MUL | NULL    |                |
| subject          | varchar(255) | NO   |     |         |                |
| description      | text         | YES  |     | NULL    |                |
| due_date         | date         | YES  |     | NULL    |                |
| category_id      | int(11)      | YES  | MUL | NULL    |                |
| status_id        | int(11)      | NO   | MUL | NULL    |                |
| assigned_to_id   | int(11)      | YES  | MUL | NULL    |                |
| priority_id      | int(11)      | NO   | MUL | NULL    |                |
| fixed_version_id | int(11)      | YES  | MUL | NULL    |                |
| author_id        | int(11)      | NO   | MUL | NULL    |                |
| lock_version     | int(11)      | NO   |     | 0       |                |
| created_on       | datetime     | YES  | MUL | NULL    |                |
| updated_on       | datetime     | YES  |     | NULL    |                |
| start_date       | date         | YES  |     | NULL    |                |
| done_ratio       | int(11)      | NO   |     | 0       |                |
| estimated_hours  | float        | YES  |     | NULL    |                |
| parent_id        | int(11)      | YES  |     | NULL    |                |
| root_id          | int(11)      | YES  | MUL | NULL    |                |
| lft              | int(11)      | YES  |     | NULL    |                |
| rgt              | int(11)      | YES  |     | NULL    |                |
| is_private       | tinyint(1)   | NO   |     | 0       |                |
| closed_on        | datetime     | YES  |     | NULL    |                |
+------------------+--------------+------+-----+---------+----------------+
24 rows in set (0.00 sec)
=end
