class DefaultIssueMember < ActiveRecord::Base
  unloadable

  self.table_name = 'users_default_issues'

  belongs_to :default_issue
  belongs_to :user
  belongs_to :issue

  def self.find_events(_, _, _, _, _)
    return []
  end
end
