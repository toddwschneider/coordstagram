Rails.application.routes.draw do
  root 'instagram_items#index'
  get '/setup' => 'instagram_items#setup', as: :setup
  get '*path' => 'instagram_items#show', as: :item_permalink
end
