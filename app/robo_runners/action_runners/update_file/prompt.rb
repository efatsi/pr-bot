module ActionRunners::UpdateFile
  class Prompt < ActionRunners::BaseActionPrompt

    def prompt_messages
      [
        { role: "system", content: PromptHub::SYSTEM_SETUP },
        { role: "user", content: action_background_prompt },
        { role: "system", content: PromptHub::ROGER_THAT },
        { role: "user", content: action_context_files },
        { role: "system", content: PromptHub::UNDERSTAND_FILES },
        { role: "user", content: instructions_prompt }
      ]
    end

    private

    def action_background_prompt
      [
        project_tools,
        "",
        "Your job will be to return the details necessary to implement the provided feature request.",
        "Do not worry about actions to other files, they will be taken care of by other actions.",
        "Return the smallest possible changeset you can think of to implement the task.",
        "",
        "Return the details of the action #{PromptHub::RETURN_AS_JSON}",
        "- file",
        "- original_content",
        "- new_content",
        "",
        "Example 1:",
        "#{JSON.pretty_generate(UPDATE_FILE_JSON_EXAMPLES[0])}",
        "",
        "Example 2:",
        "#{JSON.pretty_generate(UPDATE_FILE_JSON_EXAMPLES[1])}",
      ].join("\n")
    end

    def instructions_prompt
      [
        "This action is part of a broader feature request effort:",
        action.robo_job.feature_request,
        "",
        "The overview for this feature implementation is:",
        action.robo_job.generated_plan["overview"],
        "",
        "Fill in this action specification to accomplish the task:",
        JSON.pretty_generate(action.arguments_placeholder),
      ].join("\n")
    end

    UPDATE_FILE_JSON_EXAMPLES = [
      {
        file: "app/models/user.rb",
        original_content: "class User < ApplicationRecord\nend",
        new_content: "class User < ApplicationRecord\n  has_many :posts\nend"
      },
      {
        file: "app/views/users/show.html.erb",
        original_content: "<div class=\"mt-4 sm:mt-8\">",
        new_content: "<div class=\"mt-2 sm:mt-4\">"
      }
    ]
  end
end
