RedmineApp::Application.routes.draw do
  resources :ical_settings do
    collection do
      post "update_key"
      get "destroy"
    end
  end
  resources :exports do
    collection do
      get "ical"
    end
  end
end
