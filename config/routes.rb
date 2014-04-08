LcAgg::Application.routes.draw do
  root 'pages#latest'

  match: '/reddit'  to: 'pages#reddit',  via: 'get'
  match: '/twitter' to: 'pages#twitter', via: 'get'
  match: '/youtube' to: 'pages#youtube', via: 'get'
  match: '/about'   to: 'pages#about',   via: 'get'
  match: '/faq'     to: 'pages#faq',     via: 'get'
end
