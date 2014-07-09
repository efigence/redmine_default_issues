require_dependency 'member'

module RedmineDefaultIssues
  module Patches
    module MemberPatch
      def self.included(base) # :nodoc:
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          after_create :create_default_issues #, :unless => :issue_exists?
        end
      end

      #def issue_exists? 
      #  self.reload
      #  Issue.where(project_id: self.project_id, assigned_to_id: self.user_id).any?
      #end

      def create_issues(default_issues, root = nil, parent = nil, project_id = self.project_id)
         if default_issues.exists?
            default_issues.each do |default_issue|
              unless default_issue.user_ids.include?(self.user_id)
                i = default_issue.to_issue(self.user)
                i.root_id = root.id if root
                i.parent_id = parent.id if parent
                if i.save
                  create_issues(default_issue.children, root || i, i)
                  default_issue.users << self.user
                else
                  Rails.logger.error "--- cannot create default issue \n #{default_issue.inspect} \n #{i.errors.inspect}"
                end
              end
            end
          end
      end

      def create_default_issues
        Rails.logger.debug '---  create_default_issues'
        self.reload
        p = Project.find(self.project_id)
        self.roles.each do |role|
          if p.child? == true
            di = DefaultIssue.where(role_id: role.id, project_id: self.project_id)
            create_issues(di)
          else
            di = DefaultIssue.where(role_id: role.id, parent_id: nil)
            create_issues(di)
          end 
        end
      end

    end
  end
  unless Member.included_modules.include?(RedmineDefaultIssues::Patches::MemberPatch)
    Member.send(:include, RedmineDefaultIssues::Patches::MemberPatch)
  end
end
