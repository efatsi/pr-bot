class RoboJobStreamsController < SseApplicationController
  # Toggle this off to disable fetches to the AI API
  ROBO_ENABLED = true

  def get_contextual_files
    RoboRunnerJob.perform_later(robo_job.id, "contextual_files")
  end

  def get_instructions
    RoboRunnerJob.perform_later(robo_job.id, "instructions")
  end

  def get_followup_instructions
    RoboRunnerJob.perform_later(robo_job.id, "followup_instructions")
  end

  private

  helper_method :robo_job
  def robo_job
    @robo_job ||= RoboJob.find(params[:id])
  end
end
