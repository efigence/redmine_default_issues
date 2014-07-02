require "redmine"
require "redmine_default_issues"
require "redmine_default_issues/version"

Redmine::Plugin.register :redmine_default_issues do
  name 'Redmine default issues plugin'
  author 'Marcin Kalita'
  description "Lets you create default issue with default subissues per role. Issues will be assigned to a newly added user (having a specified role) to the project."
  version DefaultIssues::VERSION
  url 'https://github.com/efigence/redmine_default_issues'
  author_url 'http://efigence.com'
  requires_redmine :version_or_higher => "2.5.0"
  settings :partial => 'settings/default_issues', :default => {
    :show_in_top_menu => "1"
  }

  project_module :default_issues do
    permission :view_default_issues, :default_issues => [:index, :show]#, :public => false
    permission :manage_default_issues, :default_issues => [:new, :create, :edit, :update, :destroy]#, :public => false
  end

  menu :project_menu, :default_issues, {:controller => "default_issues", :action => "index"},
       :param => :project_id,
       :caption => :label_default_issue_plural
       #:if => Proc.new {
       #User.current.allowed_to?({:controller => 'default_issues', :action => 'index'}, nil, {:global => true}) && RedmineDefaultIssues.settings[:show_in_top_menu]
       #}

  menu :project_menu, :default_issues_new, {:controller => "default_issues", :action => "new"},
       :param => :project_id,
       :caption => :label_default_issue_new
       
       #:if => Proc.new {
       #User.current.allowed_to?({:controller => 'default_issues', :action => 'new'}, nil, {:global => true}) && RedmineDefaultIssues.settings[:show_in_top_menu]
       #}

  activity_provider :default_issues, :default => false, :class_name => ['DefaultIssue']
end

Rails.configuration.to_prepare do
  require "redmine_default_issues/patches/project_patch"
  require "redmine_default_issues/patches/member_patch"
  require_relative "app/helpers/default_issues_helper.rb"
  require_relative "app/concerns/default_issue_assignable.rb"
  Member.send :include, DefaultIssueAssignable
end