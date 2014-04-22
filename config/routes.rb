LcAgg::Application.routes.draw do
  root 'pages#latest'

  match '/twitter',     to: 'pages#twitter',     via: 'get'
  match '/youtube',     to: 'pages#youtube',     via: 'get'
  match '/about',       to: 'pages#about',       via: 'get'
  match '/faq',         to: 'pages#faq',         via: 'get'
  match '/reddit',      to: 'reddit_post#index', via: 'get'
  match '/reddit/:id',  to: 'reddit_post#show',  via: 'get', as: 'reddit_post'
end
