resources :projects do
  resources :default_issues do
    match '/auto_complete', :to => 'df_auto_completes#default_issues', :via => :get
    shallow do
      resources :relations, :controller => 'default_issue_relations', :only => [:index, :show, :create]
    end
  match '/relations/:id', :to => 'default_issue_relations#destroy', :via => :delete, :as => 'delete_relation'
  end
end

