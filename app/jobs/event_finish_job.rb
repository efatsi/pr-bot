class EventFinishJob < ApplicationJob
  def perform(batch, params)
    robo_event = RoboEvent.find(batch.properties[:robo_event_id])

    RoboConductor.new(robo_event).finish_request
  end
end
