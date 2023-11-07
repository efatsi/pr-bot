class RoboJobsController < ApplicationController
  include ActionController::Live

  def new
    @robo_job = RoboJob.new
  end

  def create
    @robo_job = RoboJob.new(robo_job_params)

    if robo_job.save
      redirect_to robo_job_path(robo_job)
    else
      render :new
    end
  end

  def show
  end

  def get_files
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Last-Modified'] = Time.now.httpdate

    sse = SSE.new(response.stream, event: "message")

    robo_request = robo_job.prepare_request("get_contextual_files")

    sse.write({
      turbo_stream: turbo_stream.update(
        "get-files",
        partial: "robo_jobs/files/processing",
        locals: { robo_request: robo_request }
      )
    })

    robo_job.ask_for_contextual_files(robo_request)

    sse.write({
      turbo_stream: turbo_stream.update(
        "get-files",
        partial: "robo_jobs/files/finished",
        locals: { robo_job: robo_job, robo_request: robo_request, processing: true }
      )
    })
  ensure
    sse.close
  end

  private

  helper_method :robo_job
  def robo_job
    @robo_job ||= RoboJob.find(params[:id])
  end

  def robo_job_params
    params.require(:robo_job).permit(:filepath, :feature_request, :project_context)
  end
end
