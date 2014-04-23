LcAgg::Application.routes.draw do
  resources :sessions

  root 'pages#latest'

  match '/twitter',     to: 'pages#twitter',     via: 'get'
  match '/youtube',     to: 'pages#youtube',     via: 'get'
  match '/about',       to: 'pages#about',       via: 'get'
  match '/faq',         to: 'pages#faq',         via: 'get'
  match '/reddit',      to: 'reddit_post#index', via: 'get'
  match '/reddit/:id',  to: 'reddit_post#show',  via: 'get', as: 'reddit_post'

  get 'reddit_logout', to: 'sessions#destroy', as: 'reddit_logout'
end
