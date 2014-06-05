LcAgg::Application.routes.draw do
  resources :sessions

  root 'pages#index'

  match '/twitter',       to: 'tweet#index',       via: 'get'
  match '/about',         to: 'pages#about',       via: 'get'

  match '/latest',        to: 'pages#latest',      via: 'get',
                          as: 'latest'
  match '/reddit',        to: 'reddit_post#index',    via: 'get'
  match '/reddit/:name',  to: 'reddit_post#show',     via: 'get', 
                          as: 'reddit_post'
  match '/reddit_login',  to: 'reddit_post#login',    via: 'get',
                          as: 'reddit_login'
  match '/reddit_pm',     to: 'reddit_post#pm',       via: [:get, :post],
                          as: 'reddit_pm'
  match '/new_link',      to: 'reddit_post#new_link', via: 'get',
                          as: 'reddit_link'
  match '/captcha',       to: 'reddit_post#captcha',  via: 'get'
  match '/search_reddit', to: 'reddit_post#search',   via: [:get, :post],
                          as: 'reddit_search'
  match '/inbox',         to: 'reddit_post#unread',   via: [:get, :post],
                          as: 'unread'
  
  match '/youtube',       to: 'youtube#index',        via: 'get'

  post 'send_pm',       to: 'reddit_post#send_reddit_pm', 
                        as: 'send_reddit_pm'
  post 'mark_read',     to: 'reddit_post#mark_read'
  post 'send_comment',  to: 'reddit_post#send_reddit_comment', 
                        as: 'send_reddit_comment'
  post 'submit_link',   to: 'reddit_post#submit_reddit_link', 
                        as: 'submit_reddit_link'

  get 'reddit_logout', to: 'sessions#destroy', as: 'reddit_logout'
end
