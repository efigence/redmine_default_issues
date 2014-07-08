json.array!(@default_issues) do |default_issue|
  json.extract! default_issue, :id, :subject, :description, :estimated_hours, :tracker_id, :priority_id, :role_id, :project_id, :status_id, :parent_id, :start_date, :due_date
  json.url default_issue_url(default_issue, format: :json)
end
