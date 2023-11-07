Rails.application.routes.draw do
  root "robo_jobs#new"

  resources :robo_jobs, only: [:new, :create, :show] do
    get :get_files, on: :member
  end
end
