class AskTheRobotJob < ApplicationJob
  def perform(robo_event_id, robo_request_id)
    robo_event = RoboEvent.find(robo_event_id)
    robo_request = RoboRequest.find(robo_request_id)

    RoboConductor.new(robo_event).run_request(robo_request)
  end
end
