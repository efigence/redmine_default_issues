module RedmineDefaultIssues

  def self.settings
    Setting[:plugin_redmine_default_issues].blank? ? {} : Setting[:plugin_redmine_default_issues]
  end

  # [:pl, :en]
  def self.available_locales
    Dir.glob(File.join(Redmine::Plugin.find(:redmine_default_issues).directory, 'config', 'locales', '*.yml')).collect {|f| File.basename(f).split('.').first}.collect(&:to_sym)
  end

end
