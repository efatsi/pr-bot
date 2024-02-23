module JobRunners::EnhanceFeatureRequest
  class Runner < BaseRoboRunner

    private

    alias :robo_job :parent

    def broadcast_finished_state
      broadcast(
        partial: "robo_events/list_item",
        target: "robo-event-scaffold-#{robo_event.id}",
        locals: {
          robo_event: robo_event,
          open_on_load: true,
          ding: true
        }
      )
    end

  end
end
