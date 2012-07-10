ActionController::Routing::Routes.draw do |map|
  map.resources :parents

  map.resources :developers

  map.admin_index '/admins', :controller => 'groups', :action => 'admin_index'

  map.user_edit '/users/edit', :controller => 'users', :action => 'edit'

  map.resources :users,
    :member => { :login_user => :post },
    :has_many => [:parents]

  map.resources :admins,
    :collection => { :create => :get, :logout => :get, :login => :get, :message => :get }

  map.resources :groups,
	  :collection => { :join => :get, :leave => :get, :logout => :get, :test => :get},
	  :member => { :groups => :get, :add => :post, :remove => :post }

  map.resource :session

  #Map routes
  map.root :controller => 'users', :action => 'new'
  map.admin_group_edit '/admins/group/:name/edit', :controller => 'admins', :action => 'edit'
  map.admins_group_update '/admins/group/:name/update', :controller => 'admins', :action => 'update'
  map.user_direct_message '/group/:name/direct_message', :controller => "groups", :action => "direct_message"
  map.admin_profile '/admins/group/:name', :controller => 'admins', :action => 'profile'
  map.join_group '/groups/:id/join', :controller => 'groups', :action => 'index'
  map.login '/login', :controller => 'welcome', :action => 'login'
  map.about '/about', :controller => 'welcome', :action => 'about'
  map.help '/help', :controller => 'welcome', :action => 'help'
  map.contact '/contact', :controller => 'welcome', :action => 'contact'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.profile '/group/:name', :controller => "groups", :action => "profile" 
  map.editall_admin '/admins/edit', :controller => :admins, :action => :edit_own
  map.login_admin '/admins/login', :controller => "admins", :action => "login"
  map.message_admin '/admins/message', :controller => "admins", :action => "message"
  map.messages_admin '/admins/:id/message', :controller => "admins", :action => "message"
  map.admins_users '/admins/group/:name/members/', :controller => "admins", :action => "users"
  map.direct_message '/admins/:name/direct_message', :controller => "admins", :action => "direct_msg"
  map.finalize_session 'session/finalize/:id', :controller => 'sessions', :action => 'finalize'
  map.create_session '/sessions/create/:id', :controller => 'sessions', :action => 'create'
  map.proxy_create '/account/create', :controller => 'proxy', :action => 'create'
  map.privacy '/privacy', :controller => 'welcome', :action => 'privacy'
  map.staff '/staff', :controller => 'admins', :action => 'staff'
  map.staff_edit '/staff/:id/edit', :controller => 'admins', :action => 'staff_edit'
  map.terms '/terms', :controller => 'welcome', :action => 'terms'
  map.reset_group '/admins/:id/action/reset', :controller => 'admins', :action => 'reset_group'
 # The priority is based upon order of creation: first created -> highest priority.
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'


end
