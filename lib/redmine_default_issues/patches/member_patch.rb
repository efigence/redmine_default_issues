require_dependency 'member'

module RedmineDefaultIssues
  module Patches
    module MemberPatch
      def self.included(base) # :nodoc:
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          after_create :create_default_issues
        end
      end

      def create_issues(default_issues, root = nil, parent = nil)
        if default_issues.exists?
          default_issues.each do |default_issue|
            unless default_issue.user_ids.include?(self.user_id)
              i = default_issue.to_issue(self.user)
              i.root_id = root.id if root
              i.parent_id = parent.id if parent
              if i.save!
                create_issues(default_issue.children, root || i, i)
                m = DefaultIssueMember.new
                m.issue = i
                m.default_issue = default_issue
                m.user = self.user
                m.save!
              else
                Rails.logger.error "--- cannot create default issue \n #{default_issue.inspect} \n #{i.errors.inspect}"
              end
            end
          end
        end
      end

      def create_issue_relations(default_issues)
        default_issues.each do |default_issue|
          if default_issue.relations.any?
            default_issue.relations.each do |di_relation|
              di_from = DefaultIssue.find(di_relation.default_issue_from_id)
              di_to = DefaultIssue.find(di_relation.default_issue_to_id)
              if di_from.role_id == di_to.role_id
                issue_from = DefaultIssueMember.where(user_id: self.user_id, default_issue_id: di_from.id).first.issue
                issue_to = DefaultIssueMember.where(user_id: self.user_id, default_issue_id: di_to.id).first.issue
                relation = di_relation.to_issue_relation(issue_from, issue_to)
                relation.save!
              end
            end
          end
          create_issue_relations(default_issue.children)
        end
      end

      def create_default_issues
        Rails.logger.debug '---  create_default_issues'
        self.reload
        return if principal.is_a?(Group)
        DefaultIssue.transaction do
          self.roles.each do |role|
            di = DefaultIssue.where(role_id: role.id, parent_id: nil, project_id: self.project_id)
            create_issues(di)
            create_issue_relations(di)
          end    
        end
      end
    end
  end
  unless Member.included_modules.include?(RedmineDefaultIssues::Patches::MemberPatch)
    Member.send(:include, RedmineDefaultIssues::Patches::MemberPatch)
  end
end
