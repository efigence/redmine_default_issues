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

      def create_default_issues
        Rails.logger.debug '---  create_default_issues'
        self.reload
        self.roles.each do |role|
          di = DefaultIssue.where(role_id: role.id) 
          if di.exists?
            di.each do |default_issue|
              i = default_issue.to_issue(self.user)
              unless i.save
                Rails.logger.error "--- cannot create default issue \n #{di.inspect} \n #{i.errors.inspect}"
              end
            end
          end
        end
      end

     # def add_role_to_member
      #  Rails.logger.debug '---- added_new_role_to_member'
      #  self.reload
      #  member = self.roles
     #   member << Role.find(:id)
     # end
    end
  end
  unless Member.included_modules.include?(RedmineDefaultIssues::Patches::MemberPatch)
    Member.send(:include, RedmineDefaultIssues::Patches::MemberPatch)
  end
end
