module Runners::CommitSuggestions
  class Prompt < BasePromptGenerator

    def git_commit
      @git_commit ||= robo_request.parent
    end

    def prompt_messages
      [
        { role: "system", content: PromptHub::SYSTEM_SETUP },
        { role: "user", content: commit_suggestions_prompt },
      ]
    end

    private

    def commit_suggestions_prompt
      [
        project_tools,
        "",
        include_job_requests? ? feature_requests : nil,
        ""
        "suggest 2-3 different commit messages based on the following diff:",
        project.current_diff,
        "",
        "The first 2 options should be short (under 72 characters).",
        "If the diff is sufficiently complex, include a third option that has an additional description, with max 70 characters per line.",
        "",
        "Return the options #{PromptHub::RETURN_AS_JSON}",
        "- commits: An array of commit messages to suggest, following this structure:",
        "  - message: the commit message",
        "  - description: optional, a longer description of the commit",
      ].compact.join("\n")
    end

    def feature_requests
      if parent_job = git_commit.robo_job
        [
          "You are helping to implement these feature request(s):",
          *parent_job.all_feature_requests,
        ].join("\n")
      end
    end

    def include_job_requests?
      git_commit.robo_job.present?
    end
  end
end
