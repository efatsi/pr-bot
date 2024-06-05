class ImagePreviewsController < ApplicationController
  def show
    @image = robo_job.images.find(params[:id])
  end

  private

  def robo_job
    @robo_job ||= RoboJob.find(params[:robo_job_id])
  end
end
