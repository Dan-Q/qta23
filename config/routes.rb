Rails.application.routes.draw do
  post 'login' => 'main#login'
  get 'logout' => 'main#logout'
  post 'rsvp' => 'main#rsvp'
  get 'ics' => 'main#ics'
  post 'remind' => 'main#remind'

  # Magic login links:
  get 'invite/:code' => 'main#login'

  # Admin:
  resources :invitations do
    member do
      post 'infiltrate'
    end
  end

  root 'main#index'
end
