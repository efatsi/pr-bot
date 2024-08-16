class Api::RoboJobsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    input_string = params[:input_string]
    pathnames = input_string.scan(/django\/[^\s:]+/).map { |path| path.sub('django/', '') }
    feature_request = input_string.gsub(/django\/[^\s:]+/, '').strip

    robo_job = RoboJob.new(
      feature_request: feature_request,
      seed_contextual_files: pathnames,
      project_id: params[:project_id]
    )

    if robo_job.save
      render json: { status: 'success', robo_job: robo_job }, status: :created
    else
      render json: { status: 'error', errors: robo_job.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
