Rails.application.routes.draw do
  post '/readings', to: "readings#create"
  get  '/readings', to: "readings#show"
  get  '/stats', to: "stats#show"

  # To handle routing errors
  post '*path', :to => 'application#routing_error'
  get '*path', :to => 'application#routing_error'
end
