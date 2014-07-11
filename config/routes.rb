resources :projects do
  resources :default_issues do
    shallow do
      resources :relations, :controller => 'default_issue_relations', :only => [:index, :show, :create, :destroy]
    end
  end
end

match '/default_issues/auto_complete', :to => 'df_auto_completes#default_issues', :via => :get, :as => 'df_auto_complete_default_issues'

#resources :default_issues do
 
#end