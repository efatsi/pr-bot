module JobRunners::CommitSuggestions
  class Runner < BaseRoboRunner

    private

    alias :git_commit :subject

    def robo_job
      @robo_job ||= git_commit.robo_job
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

  end
end
