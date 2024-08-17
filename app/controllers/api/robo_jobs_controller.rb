class Api::RoboJobsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    input_string = params[:input_string]
    pathnames = input_string.scan(/django\/[^\s:]+/).map { |path| path.sub("django/", "") }
    # strip out django/ prefix, leave rest of path
    feature_request = input_string.gsub(/django\//, "").strip

    robo_job = RoboJob.new(
      feature_request: feature_request,
      seed_contextual_files: pathnames,
      project_id: params[:project_id]
    )

    if robo_job.save
      start_event = robo_job.robo_events.create(event_type: "start")
      build_event = robo_job.robo_events.create(
        event_type: "build_instructions",
        robots: ["gpt-4"],
        parent_robo_event: start_event
      )
      RoboConductor.new(build_event).start_event

      render json: { status: "success", robo_job: robo_job.id, build_event: build_event.id }, status: :created
    else
      render json: { status: "error", errors: robo_job.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
