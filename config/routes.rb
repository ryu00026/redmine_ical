ActionController::Routing::Routes.draw do |map|
  map.connect "ical_settings/:action", :controller => "ical_settings"
  map.connect "exports/:action", :controller => "exports"
end
