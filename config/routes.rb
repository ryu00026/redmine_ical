RedmineApp::Application.routes.draw do
  resources :ical_settings do
    collection do
      post "update_key"
    end
  end
  resources :exports do
    member do
      get "ical"
    end
  end
end
