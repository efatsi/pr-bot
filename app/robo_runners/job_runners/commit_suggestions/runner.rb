module JobRunners::CommitSuggestions
  class Runner < BaseRoboRunner

    private

    # Override broadcast methods since commit suggestions are added to existing event
    def broadcast_event_scaffold
      broadcast(
        partial: "robo_events/in_flight_requests",
        target: "commit-suggestions-#{git_commit.id}",
        action: :update,
        locals: {
          robo_event: robo_event,
          robo_requests: robo_requests,
        }
      )
    end

    def broadcast_finished_state
      broadcast(
        partial: "robo_events/git_commit/suggestions",
        target: "commit-suggestions-#{git_commit.id}",
        action: :replace,
        locals: {
          robo_event: robo_event,
        }
      )
    end

    alias :git_commit :subject

    def robo_job
      @robo_job ||= git_commit.robo_job
    end

  end
end
