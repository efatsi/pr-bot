class PromptGenerator
  RETURN_AS_JSON = "Return the details of the implementation change as a JSON object with the following structure:"

  attr_reader :robo_request

  delegate :robo_job, :project, to: :robo_request

  def initialize(robo_request)
    @robo_request = robo_request
  end

  def generate_prompt
    case robo_request.request_type
    when "contextual_files"
      contextual_files_prompt
    when "instructions"
      instructions_prompt
    end
  end

  def contextual_files_prompt
    [
      "What files from the Directory Tree should I review to implement the following feature request in this project?",
      "Directory Tree:",
       project.fetch_directory_tree.join("\n"),
      "",
      "Feature request:",
      robo_job.feature_request,
      "",
      "You are working on a project with these tools:\n" + project.project_context,
      "Be very concise in your response, return exact file names for files that would provide helpful context.",
    ].join("\n")
  end

  def instructions_prompt
    [
      "You are working on a project with these tools:\n" + project.project_context,
      "",
      "These are relevant project files:",
      robo_job.contextual_file_data,
      "",
      "How would you implement this feature request?",
      robo_job.feature_request,
      "",
      "Prefer solutions that use the project tools over generic solutions.",
      "",
      RETURN_AS_JSON,
      "- implementation_overview: Describe the steps involved to implement the feature",
      "- additional_notes: Any other details to know, or steps to take after the implementation is complete",
      "- changes: An array of all the file changes required, following this structure:",
      "  - summary: A brief description of the change",
      "  - action: one of `#{RoboChange::VALID_ACTIONS.join('`, `')}`",
      "  - file: path to the file",
      "  - original_content: the exact content of the file, only that which will be changed by the new_content",
      "  - new_content: the new content required for the feature",
      "",
      "Example",
      "#{FULL_JSON_EXAMPLE}"
    ].join("\n")
  end

  FULL_JSON_EXAMPLE = JSON.pretty_generate({
    "implementation_overview": "We need to add a new member route to the robo_jobs resources in the routes.rb file and create a new controller action along with a corresponding template file.",
    "changes": [
      {
        "summary": "Add a new `:robo_requests` member route to the `robo_jobs` resources",
        "action": "update_file",
        "file": "/pr-bot/config/routes.rb",
        "original_content": "resources :robo_jobs, only: [:new, :create, :show, :edit, :update] do",
        "new_content": "resources :robo_jobs, only: [:new, :create, :show, :edit, :update] do\n    get :robo_requests, on: :member"
      },
      {
        "summary": "Add a new `robo_requests` action to the `RoboJobsController`.",
        "action": "update_file",
        "file": "/pr-bot/app/controllers/robo_jobs_controller.rb",
        "orginal_content": "end\n\n  private",
        "new_content": "end\n\n  def robo_requests\n    @robo_job = RoboJob.find(params[:id])\n  end\n\n  private"
      },
      {
        "summary": "Add a new template file for the `robo_requests` action.",
        "action": "add_file",
        "file": "/pr-bot/app/views/robo_jobs/robo_requests.html.erb",
        "original_content": "",
        "new_content": "<h1>Robo Requests for <%= @robo_job.name %></h1>\n<% @robo_job.robo_requests.each do |request| %>\n  <div class=\"robo-request\">\n  </div>\n<% end %>"
      }
    ],
    "additional_notes": "Check that the template is being rendered correctly at the path `/robo_jobs/:id/robo_requests`."
  })

end
