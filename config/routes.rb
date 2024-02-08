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
    post :get_contextual_files, on: :member
    post :build_plan, on: :member
    post :get_instructions, on: :member
    post :get_followup_instructions, on: :member

    get :info, on: :member
    patch :update_files, on: :member

    resources :actions, only: [] do
      get :execute_all, on: :collection
      post :execute, on: :member
      post :reset, on: :member
      post :skip, on: :member
      post :unexecute, on: :member
      post :unskip, on: :member
    end

    resources :followup_jobs, only: [:new, :create]
  end

  mount GoodJob::Engine => 'good_job'
end
