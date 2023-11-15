Rails.application.routes.draw do
  root "projects#index"

  resources :projects, except: :destroy do
    get :fuzzy_file_finder, on: :member
  end

  resources :robo_jobs, except: :destroy do
    [
      :get_contextual_files,
      :get_instructions,
      :get_followup_instructions,
    ].each do |action|
      get action, on: :member, to: "robo_job_streams##{action}"
    end

    patch :update_files, on: :member

    resources :robo_changes, only: [] do
      get :execute_all, on: :collection
      post :execute, on: :member
      post :skip, on: :member
    end

    resources :followup_jobs, only: [:new, :create]
  end
end
