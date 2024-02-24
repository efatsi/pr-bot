class EventConductorJob < ApplicationJob
  def perform(global_id, action)
    resource = GlobalID::Locator.locate(global_id)
    robo_event = resource.robo_events.create!(
      event_type: action,
      parent_robo_event: resource.last_active_event
    )

    RoboConductor.new(robo_event).run_request
  end
end
