class EventConductorJob < ApplicationJob
  def perform(event_id)
    robo_event = RoboEvent.find(event_id)

    RoboConductor.new(robo_event).run_request
  end
end
