class RoboChannel < ActionCable::Channel::Base
  def subscribed
    @robo_job = RoboJob.find_by!(id: params[:robo_job_id])

    stream_from @robo_job.stream_key
  end
end
