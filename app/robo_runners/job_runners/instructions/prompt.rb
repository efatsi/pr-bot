module JobRunners::Instructions
  class Prompt < BasePromptGenerator

    alias :robo_job :subject

    def prompt_messages
      [
        { role: "user", content: PromptHub::SYSTEM_SETUP },
        { role: "system", content: PromptHub::ROGER_THAT },
        { role: "user", content: robo_job_context_files },
        { role: "system", content: PromptHub::UNDERSTAND_FILES },
        { role: "user", content: instructions_prompt },
        { role: "system", content: PromptHub::ROGER_THAT },
        { role: "user", content: final_request_prompt }
      ]
    end

    private

    def instructions_prompt
      [
        project_tools,
        "",
        "Return the details of the implementation change #{PromptHub::RETURN_AS_JSON}",
        "- implementation_overview: Describe the steps involved to implement the feature, and any follow-up steps to take afterwards",
        "- changes: An array of all the file changes required, following this structure:",
        "  - summary: A brief description of the change",
        "  - action: one of `#{Action.action_templates.map{|a| a[:name]}.join('`, `')}`",
        "  - file: source file path",
        "  - new_file: destination file path (only required for `rename_file` action)",
        "  - original_content: exact text which needs to be replaced by the new_content. Do not summarize. Return full existing snippets of code from the source file. Do not return blank here. For new text, return a small snippet of existing code to 'anchor' the change to (eg: a function definition).",
        "  - new_content: the new content required for the feature",
        "",
        "When generating the array of changes, prefer lots of individual changes for distinct functional updates instead of one big one.",
        "",
        "Example",
        "#{IMPLEMENTATION_JSON_EXAMPLE}"
      ].join("\n")
    end

    def final_request_prompt
      robo_job.enhanced_feature_request
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
