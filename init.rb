require 'redmine'

# This is the important line.
# It requires the file in lib/my_plugin/hooks.rb
# require_dependency 'redmine_default_issues/hooks'

Redmine::Plugin.register :redmine_default_issues do
  name 'Redmine default issues plugin'
  author 'Marcin Kalita'
  description "Lets you create default issue with default subissues per role. Issues will be assigned to a newly added user (having a specified role) to the project."
  version '0.0.1'
  url 'https://github.com/efigence/redmine_default_issues'
  author_url 'http://efigence.com'

  #settings :default => {}, :partial => 'settings/default_issues_settings'
end

#require_relative 'app/helpers/application_helper.rb'
require_relative 'app/concerns/default_issues.rb'
Member.send :include, DefaultIssues

#require 'redmine_default_issues/hooks/default_issues_hook'
