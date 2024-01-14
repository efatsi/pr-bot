module JobRunners::Instructions
  class Prompt < BasePromptGenerator

    def prompt_messages
      [
        { role: "system", content: PromptHub::SYSTEM_SETUP },
        { role: "user", content: instructions_background_prompt },
        { role: "system", content: "I understand. Let's get started!" },
        { role: "user", content: relevant_files_prompt },
        { role: "system", content: "I see these are the current files and will use them as strong references." },
        { role: "user", content: instructions_prompt }
      ]
    end

    private

    def robo_job
      @robo_job ||= robo_request.parent
    end

    def instructions_background_prompt
      [
        "You are working on a project with these tools:",
        project.project_context,
        "",
        "Prefer solutions that use the project tools over generic solutions.",
        "",
        "Return the details of the implementation change #{PromptHub::RETURN_AS_JSON}",
        "- implementation_overview: Describe the steps involved to implement the feature, and any follow-up steps to take afterwards",
        "- changes: An array of all the file changes required, following this structure:",
        "  - summary: A brief description of the change",
        "  - action: one of `#{Action.action_templates.map{|a| a[:name]}.join('`, `')}`",
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
      [
        "These are relevant project files:",
        robo_job.contextual_file_data,
      ].join("\n")
    end

    def instructions_prompt
      [
        "How would you implement this feature request?",
        robo_job.feature_request,
      ].join("\n")
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
end
