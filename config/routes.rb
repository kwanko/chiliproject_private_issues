#-- encoding: UTF-8
ActionController::Routing::Routes.draw do |map|
  map.connect "private_issues/sendparentchildprivateissue", :controller => "private_issues", :action => "sendparentchildprivateissue"
end
