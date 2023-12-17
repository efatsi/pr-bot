class RoboJobStreamsController < SseApplicationController
  # Toggle this off to disable fetches to the AI API
  ROBO_ENABLED = true

  def get_contextual_files
    UniversalRunnerJob.perform_later(robo_job.to_global_id.to_s, "contextual_files")
  end

  def get_instructions
    UniversalRunnerJob.perform_later(robo_job.to_global_id.to_s, "instructions")
  end

  private

  helper_method :robo_job
  def robo_job
    @robo_job ||= RoboJob.find(params[:id])
  end
end
