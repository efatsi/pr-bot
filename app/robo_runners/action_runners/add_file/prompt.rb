module ActionRunners::AddFile
  class Prompt < ActionRunners::BaseActionPrompt

    private

    def action_background_prompt
      [
        project_tools,
        "",
        "Your job is to return the details necessary to implement the provided feature request.",
        "Do not worry about actions to other files, they will be taken care of by other actions.",
        "Return the smallest possible changeset necessary to clearly implement the task.",
        "",
        "Return the details of the action #{PromptHub::RETURN_AS_JSON}",
        "- file",
        "- new_content",
        "",
        "Here are some examples:",
        *action_example_prompts,
      ].join("\n")
    end

    def action_examples
      [
        {
          file: "app/models/user.rb",
          new_content: "class User < ApplicationRecord\nend"
        },
        {
          file: "app/views/users/show.html.erb",
          new_content: "<div>User show page</div>"
        }
      ]
    end

  end
end
