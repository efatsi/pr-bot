module JobRunners::CommitSuggestions
  class Runner < BaseRoboRunner

    alias :git_commit :parent

    private

    def robo_job
      @robo_job ||= git_commit.robo_job
    end

    def broadcast_processing_state
      broadcast(
        partial: 'git_commits/suggestions/processing',
        locals: { robo_request: robo_request }
      )
    end

    def handle_response
      git_commit.update(message_options: JSON.parse(robo_request.response))
    end

    def broadcast_finished_state
      broadcast(
        partial: 'git_commits/suggestions/finished',
        locals: { robo_request: robo_request, git_commit: git_commit }
      )
    end

    def primary_target
      "commit-suggestions"
    end

    def primary_label
      "Commit Suggestions"
    end
  end
end
