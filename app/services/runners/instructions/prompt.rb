module Runners
  class Instructions::Prompt < BasePromptGenerator
    PLAN_SYSTEM_SETUP = "You are a senior full-stack web developer, and expert code system architect."

    def prompt_messages
      [
        { role: "system", content: PLAN_SYSTEM_SETUP },
        { role: "user", content: build_plan_background_prompt },
        *previous_convo_messages,
        { role: "user", content: relevant_files_prompt },
        { role: "user", content: instructions_prompt }
      ]
    end

    private

    def robo_job
      @robo_job ||= robo_request.parent
    end

    def build_plan_background_prompt
      [
        "You are working on a project with these tools:",
        project.project_context,
        "",
        "Prefer solutions that use the project tools over generic solutions.",
        "",
        "Here are the relevant CONTEXT_FILES to help inform the plan:",
        robo_job.contextual_file_data,
        "",
        "Here are the available ACTION_TEMPLATES for building a plan:",
        action_templates,
        "",
        "Your job is to create a plan of actions to implement the solution..",
        "",
        "Return the details of the build plan \(RETURN_AS_JSON)",
        "- overview: Explain at high level what the plan is to implement the feature request",
        "- build_plan: An array of valid actions available in the ACTION_TEMPLATES schema",
        "  - action_type: One of the available ACTION_TEMPLATES",
        "  - summary: Summarize the implementation required",
        "  - arguments: Array for each defined argument",
        "    - key: value",
        "  - relevant_files: Array of files that would help inform the action implementation. If no files are necessary, return an empty array",
        "    - filepath: Exact path of file",
        "",
        "Example",
        "#{PLAN_JSON_EXAMPLE}"
      ].join("\n")
    end

    # TODO: abstract this out to a module
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


    def action_templates
      ActionTemplate.ensure_system_templates

      ActionTemplate.system_templates.map do |template|
        [
          "- action_type: #{template.name}",
          "  - description: #{template.description}",
          "  - arguments: [#{template.plan_arguments}]"
        ]
      end.join("\n")
    end

    def previous_convo_messages
      # TODO: implement
      []
    end

    PLAN_JSON_EXAMPLE = JSON.pretty_generate(
    {
      "overview": "Implement a new member route for robo_requests within the robo_jobs resources, including a controller action, corresponding template, and a migration to add robo_job_id to robo_requests.",
      "build_plan": [
        {
          "action_type": "update_file",
          "summary": "Add a new `:robo_requests` member route to the `robo_jobs` resources.",
          "arguments": {
            "file": "config/routes.rb",
          },
          "relevant_files": ["config/routes.rb"]
        },
        {
          "action_type": "update_file",
          "summary": "Add a new `robo_requests` action to the `RoboJobsController`.",
          "arguments": {
            "file": "app/controllers/robo_jobs_controller.rb",
          },
          "relevant_files": ["app/controllers/robo_jobs_controller.rb"]
        },
        {
          "action_type": "add_file",
          "summary": "Add a new template file for the `robo_requests` action.",
          "arguments": {
            "file": "app/views/robo_jobs/robo_requests.html.erb",
          },
          "relevant_files": []
        },
        {
          "action_type": "add_file",
          "summary": "Create a migration to add robo_job_id to robo_requests.",
          "arguments": {
            "file": "/db/migrate/[timestamp]_add_robo_job_id_to_robo_requests.rb",
          },
          "relevant_files": []
        }
      ]
    })
  end
end
