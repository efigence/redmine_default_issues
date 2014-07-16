resources :projects do
  resources :default_issues do
    get '/auto_complete', :to => 'df_auto_completes#default_issues'
    shallow do
      resources :relations, :controller => 'default_issue_relations', :only => [:index, :show, :create]
    end
  match '/relations/:id', :to => 'default_issue_relations#destroy', :via => :delete, :as => 'delete_relation'
  end
end

