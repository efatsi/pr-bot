Rails.application.routes.draw do
  root "robo_jobs#new"

  resources :robo_jobs, only: [:new, :create, :show, :edit, :update] do
    [
      :get_contextual_files,
      :get_instructions,
    ].each do |action|
      get action, on: :member, to: "robo_job_streams##{action}"
      patch :update_files, on: :member

      resources :robo_changes, only: [] do
        get :execute_all, on: :collection
        post :execute, on: :member
      end

    end
  end
end
