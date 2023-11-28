Rails.application.routes.draw do
  root "projects#index"

  resources :projects, except: :destroy do
    get :fuzzy_finder, on: :member
    get :file_name_search, on: :member
    get :file_content_search, on: :member
    get :file_preview, on: :member
    get :full_directory_listing, on: :member

    resources :git_commits, only: [:new, :edit, :update] do
      get :generate_options, on: :member
    end
  end

  resources :robo_jobs, except: :destroy do
    [
      :get_contextual_files,
      :get_instructions,
      :get_followup_instructions,
    ].each do |action|
      get action, on: :member, to: "robo_job_streams##{action}"
    end

    get :info, on: :member
    patch :update_files, on: :member

    resources :robo_changes, only: [] do
      get :execute_all, on: :collection
      post :execute, on: :member
      post :skip, on: :member
      post :unexecute, on: :member
      post :unskip, on: :member
    end

    resources :followup_jobs, only: [:new, :create]
  end
end
