module DefaultIssues
  extend ActiveSupport::Concern

  def assign_default_issues
    # TODO
  end

  included do
    after_create :assign_default_issues
  end
end
