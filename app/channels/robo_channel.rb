class RoboChannel < ActionCable::Channel::Base
  def subscribed
    @robo_job = RoboJob.find_by!(id: params[:robo_job_id])

    stream_from "robo_channel_#{@robo_job.id}"
  end
end
