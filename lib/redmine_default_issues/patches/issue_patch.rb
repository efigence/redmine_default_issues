require_dependency 'issue'

module RedmineDefaultIssues
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc:
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          has_many :default_issue_members, :dependent => :delete_all
        end
      end
    end
  end
end

unless Issue.included_modules.include?(RedmineDefaultIssues::Patches::IssuePatch)
  Issue.send(:include, RedmineDefaultIssues::Patches::IssuePatch)
end
