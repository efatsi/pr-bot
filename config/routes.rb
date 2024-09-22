Rails.application.routes.draw do
  root "projects#index"

  resources :projects, except: :destroy do
    get :fuzzy_finder, on: :member
    get :file_name_search, on: :member
    get :file_content_search, on: :member
    get :file_preview, on: :member
    get :full_directory_listing, on: :member
  end

  resources :robo_jobs, except: :destroy do
    get :edit_feature_and_files, on: :member

    resources :robo_events, only: :create

    resources :contextual_files, only: [] do
      post :accept, on: :member
      post :ignore, on: :member
      post :reset, on: :member
    end

    resources :followup_jobs, only: [:new, :create] do
      post :create_retry, on: :collection
    end

    resources :git_commits, only: [:new, :update]

    resources :image_previews, only: [:show]
  end

  resources :robo_events, only: [:destroy] do
    post :new_retry, on: :member
    get :show_sibling, on: :member
    post :reset_to_here, on: :member
    get :show_next_steps, on: :member
  end

  resources :robo_requests, only: [:show] do
    get :conversation, on: :member
    post :accept, on: :member
    post :ignore, on: :member

    get :edit_enhanced_feature_request
    patch :update_enhanced_feature_request

    resources :actions, only: [] do
      get :execute_all, on: :collection
    end
  end

  resources :actions, only: [] do
    post :execute, on: :member
    post :reset, on: :member
    post :skip, on: :member
    post :unexecute, on: :member
    post :unskip, on: :member
  end

  resources :git_commits, only: [] do
    post :generate_options, on: :member
  end

  mount GoodJob::Engine => 'good_job'
end
