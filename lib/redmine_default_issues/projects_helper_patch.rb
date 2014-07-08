require_dependency 'projects_helper'

module RedmineDefaultIssues::ProjectsHelperPatch

  def self.included(base)
    base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        alias_method_chain :project_settings_tabs, :redmine_default_issues
      end
  end

  module InstanceMethods
    
    def project_settings_tabs_with_redmine_default_issues
     @tabs = project_settings_tabs_without_redmine_default_issues
     @action = {:name => 'new_default_issues', :action => :manage_default_issues, :partial => 'default_issues/new', :label => :label_default_issue_new}
     @tabs << @action        
     @tabs   
    end
  end
end