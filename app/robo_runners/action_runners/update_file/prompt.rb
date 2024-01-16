module ActionRunners::UpdateFile
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
        "- original_content",
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
          original_content: "class User < ApplicationRecord\nend",
          new_content: "class User < ApplicationRecord\n  has_many :posts\nend"
        },
        {
          file: "app/views/users/show.html.erb",
          original_content: "<div class=\"mt-4 sm:mt-8\">\n          <p>Don't want to wait?</p>\n          <%= link_to \"Find Local Quiz\", root_url, class: \"btn-primary\" %>\n        </div>",
          new_content: "<div class=\"mt-2 sm:mt-4\">\n          <p>Don't want to wait?</p>\n          <%= link_to \"Find Local Quiz\", root_url, class: \"btn-primary\" %>\n        </div>"
        }
      ]
    end

  end
end
