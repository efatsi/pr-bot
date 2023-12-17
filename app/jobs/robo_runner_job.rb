# shouldn't have named the primary model `RoboJob`, oh well!

class RoboRunnerJob < ApplicationJob
  def perform(robo_job_id, action)
    robo_job = RoboJob.find(robo_job_id)

    RoboManager.new(robo_job, action).run_request
  end
end
