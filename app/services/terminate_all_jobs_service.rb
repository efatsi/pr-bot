class TerminateAllJobsService
  def self.call(reason: "Terminated by system")
    new.call(reason)
  end

  def call(reason)
    processing_jobs = GoodJob::Job.where(finished_at: nil)
    processing_jobs.find_each do |job|
      job.force_discard_job(reason)
      log_termination(job, reason)
    rescue StandardError => e
      handle_error(job, e)
    end
  end

  private

  def log_termination(job, reason)
    Rails.logger.info("Job ##{job.id} has been terminated. Reason: #{reason}")
  end

  def handle_error(job, exception)
    Rails.logger.error("Failed to terminate job ##{job.id}: #{exception.message}")
  end
end
