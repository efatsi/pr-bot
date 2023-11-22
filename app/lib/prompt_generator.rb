class PromptGenerator
  SYSTEM_SETUP = "You are a senior web developer, UI/UX developer, and expert code system architect."

  RETURN_IMPLEMENTATION_AS_JSON = "Return the details of the implementation change as a JSON object with the following structure:"
  RETURN_COMMITS_AS_JSON = "Return the options as a JSON object with the following structure:"

  JSON_RETURNS = [
    RETURN_IMPLEMENTATION_AS_JSON,
    RETURN_COMMITS_AS_JSON,
  ]

  attr_reader :robo_request

  delegate :project, to: :robo_request

  def initialize(robo_request)
    @robo_request = robo_request
  end

  def generate_prompt
    case robo_request.request_type
    when "contextual_files"
      contextual_files_prompt
    when "instructions"
      instructions_prompt
    when "commit_suggestions"
      commit_suggestions_prompt
    end
  end

  def contextual_files_prompt
    robo_job = robo_request.parent

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
    robo_job = robo_request.parent

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
      RETURN_IMPLEMENTATION_AS_JSON,
      "- implementation_overview: Describe the steps involved to implement the feature",
      "- additional_notes: Any other details to know, or steps to take after the implementation is complete",
      "- changes: An array of all the file changes required, following this structure:",
      "  - summary: A brief description of the change",
      "  - action: one of `#{RoboChange::VALID_ACTIONS.join('`, `')}`",
      "  - file: source file path",
      "  - new_file: destination file path (only required for `rename_file` action)",
      "  - original_content: the exact text which needs to be replaced by the new_content. Do not summarize. Return full existing snippets of code from the source file.",
      "  - new_content: the new content required for the feature",
      "",
      "Example",
      "#{IMPLEMENTATION_JSON_EXAMPLE}"
    ].join("\n")
  end

  def commit_suggestions_prompt
    to_return = [
      "You are working on a project with these tools:\n" + project.project_context,
      "",
    ]

    # parent is always a GitCommit, which is optionally tied to a RoboJob
    if parent_job = robo_request.parent.robo_job
      to_return += [
        "You are helping to implement these feature request(s):",
        *parent_job.all_feature_requests,
      ]
    end

    to_return += [
      "suggest 2-3 different commit messages based on the following diff:",
      project.current_diff,
      "",
      "The first 2 options should be short (under 72 characters). If the diff is sufficiently complex, include a third option that has an additional description, with max 70 characters per line.",
      "",
      RETURN_COMMITS_AS_JSON,
      "- commits: An array of commit messages to suggest, following this structure:",
      "  - message: the commit message",
      "  - description: optional, a longer description of the commit",
    ]

    to_return.join("\n")
  end

  IMPLEMENTATION_JSON_EXAMPLE = JSON.pretty_generate({
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

  # COMMITS_JSON_EXAMPLE = JSON.pretty_generate({
  #   "commits": [
  #     {
  #       "message": "Add the ability to edit and update robo_requests"
  #     },
  #     {
  #       # similar to the above message but worded differently
  #       "message": "
  #     }

end
