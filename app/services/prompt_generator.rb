DUMMY_MODE = false

class PromptGenerator
  SYSTEM_SETUP = "You are a senior web developer, 10x developer, UI/UX developer, and expert code system architect. When working/responding, take a deep breath and work step-by-step."
  RETURN_AS_JSON = "as a JSON object with the following structure:"

  attr_reader :robo_request

  delegate :project, to: :robo_request

  def initialize(robo_request)
    @robo_request = robo_request
  end

  def prompt_messages
    if DUMMY_MODE
      return [
        { role: "system", content: "You are a bird scientist." },
        { role: "user", content: "Tell me a cool fact about migratory birds that I didn't know. In about 100 words." }
      ]
    end

    if robo_request.request_type.in?(["instructions", "followup_instructions"])
      # this might have a conversation history, structure it differently
      instructions_prompt_messages

    else
      # these are more straightforward, just one system/user pair
      user_prompt = if robo_request.request_type == "contextual_files"
        contextual_files_prompt
      elsif robo_request.request_type == "commit_suggestions"
        commit_suggestions_prompt
      end

      [
        { role: "system", content: PromptGenerator::SYSTEM_SETUP },
        { role: "user", content: user_prompt }
      ]
    end
  end

  def instructions_prompt_messages
    [
      { role: "system", content: PromptGenerator::SYSTEM_SETUP },
      { role: "user", content: instructions_background_prompt },
      { role: "user", content: relevant_files_prompt },
      *previous_convo_messages,
      { role: "user", content: instructions_prompt }
    ]
  end

  def contextual_files_prompt
    robo_job = robo_request.parent

    [
      "You are working on a project with these tools:\n" + project.project_context,
      "",
      "What files from the Directory Tree should I review to implement the following feature request in this project?",
      "Directory Tree:",
      project.fetch_directory_tree.join("\n"),
      "",
      "Feature request:",
      robo_job.feature_request,
      "",
      "Return paths for files that would provide helpful context #{RETURN_AS_JSON}",
      "- files: An array of files worth investigating:",
      "  - filpath: exact path of file",
      "  - why: explain why this is relevant to the feature request",
    ].join("\n")
  end

  def instructions_background_prompt
    robo_job = robo_request.parent

    [
      "You are working on a project with these tools:",
      project.project_context,
      "",
      "Prefer solutions that use the project tools over generic solutions.",
      "",
      "Return the details of the implementation change #{RETURN_AS_JSON}",
      "- implementation_overview: Describe the steps involved to implement the feature, and any follow-up steps to take afterwards",
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

  def relevant_files_prompt
    robo_job = robo_request.parent

    [
      "These are relevant project files:",
      robo_job.contextual_file_data,
    ].join("\n")
  end

  def instructions_prompt
    robo_job = robo_request.parent

    [
      "How would you implement this feature request?",
      robo_job.feature_request,
    ].join("\n")
  end

  def previous_convo_messages
    robo_job = robo_request.parent
    parent_job = robo_job.parent_job

    if robo_job.include_last_convo?
      last_job = parent_job.followup_jobs.to_a.reverse.detect{|a| a.robo_changes.any?} || parent_job
      [
        { role: "user", content: last_job.feature_request },
        { role: "system", content: last_job.generated_instructions.to_s },
      ]

    elsif robo_job.include_all_convos?
      [robo_job.parent_job, *robo_job.parent_job.followup_jobs].flat_map do |job|
        if job.robo_changes.any?
          [
            { role: "user", content: job.feature_request },
            { role: "system", content: job.generated_instructions.to_s },
          ]
        end
      end.compact
    end
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
      "Return the options #{RETURN_AS_JSON}",
      "- commits: An array of commit messages to suggest, following this structure:",
      "  - message: the commit message",
      "  - description: optional, a longer description of the commit",
    ]

    to_return.join("\n")
  end

  IMPLEMENTATION_JSON_EXAMPLE = JSON.pretty_generate({
    "implementation_overview": "Add a new member route to the robo_jobs resources in the routes.rb file and create a new controller action along with a corresponding template file. After implementing, check that the template is being rendered correctly at the path `/robo_jobs/:id/robo_requests`",
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
        "new_content": "<h1>Robo Requests for <%= @robo_job.name %></h1>\n<% @robo_job.robo_requests.each do |request| %>\n  <div class=\"robo-request\">\n  </div>\n<% end %>"
      },
      {
        "summary": "Create a migration to add robo_job_id to robo_requests.",
        "action": "add_file",
        "file": "/db/migrate/[timestamp]_add_robo_job_id_to_robo_requests.rb",
        "new_content": "class AddRoboJobIdToRoboRequests < ActiveRecord::Migration[6.1]\n  def change\n    add_reference :robo_requests, :robo_job, null: false, foreign_key: true\n  end\nend"
      }
    ],
  })
end
