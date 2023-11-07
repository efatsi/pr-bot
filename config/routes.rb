Rails.application.routes.draw do
  root "robo_jobs#new"

  resources :robo_jobs, only: [:new, :create, :show] do
    [
      :get_contextual_files,
      :get_instructions,
    ].each do |action|
      get action, on: :member, to: "robo_job_streams##{action}"
    end
  end
end
