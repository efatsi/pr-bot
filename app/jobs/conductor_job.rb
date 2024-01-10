class ConductorJob < ApplicationJob
  def perform(global_id, action)
    resource = GlobalID::Locator.locate(global_id)
    RoboConductor.new(resource, action).run_request
  end
end
