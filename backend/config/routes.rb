require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do

  mount Sidekiq::Web => '/admin/sidekiq', :constraints => AdminConstraint.new
  mount ActionCable.server => '/cable'
  
  root to: 'index#landing'

  get 'notify/:txid', to: 'index#notify'
  
  # Admin
  get  '/admin/login',                            to: 'admin/auth#login_form'
  post '/admin/login',                            to: 'admin/auth#login'
  get  '/admin/logout',                           to: 'admin/auth#logout'

  get  '/admin',                                  to: 'admin/dashboard#index'
  get  '/admin/payouts',                          to: 'admin/payouts#index'
  put  '/admin/payouts/:ledger_entry_id/approve', to: 'admin/payouts#approve'
  
  # Sitemap
  get 'sitemap.xml', to: 'index#sitemap', defaults: {format: 'xml'}

  scope module: :api, defaults: {format: 'json'} do

    post '/auth/sessions',                  to: 'auth#create_session'
    post '/auth/login',                     to: 'auth#login'
    post '/auth/signup',                    to: 'auth#signup'
    post '/auth/activate',                  to: 'auth#activate'
    post '/auth/send_reset_link',           to: 'auth#send_reset_link'
    post '/auth/validate_pass_reset_token', to: 'auth#validate_pass_reset_token'
    post '/auth/reset_password',            to: 'auth#reset_password'

    get  '/leagues',                        to: 'leagues#index'
    
    get  '/leagues/:league_handle/matches', to: 'matches#index'
    get  '/matches/:id',                    to: 'matches#show'
    
    get  '/played_matches',                 to: 'matches#played_matches'
    
    post '/matches/:match_id/plays',        to: 'plays#create'
    get  '/matches/:match_id/plays',        to: 'plays#get_match_plays'
    
    get  '/addresses/:code',                to: 'addresses#show'
    
    get  '/notifs',                         to: 'notifs#index'
    get  '/board_notifs',                   to: 'notifs#get_board_notifs'
    put  '/notifs/mark_as_seen',            to: 'notifs#mark_as_seen'

    get  '/ledger_entries',                 to: 'ledger_entries#index'

    post '/payouts',                        to: 'payouts#create'
  end
end
