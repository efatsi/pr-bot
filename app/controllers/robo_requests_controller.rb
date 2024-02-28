class RoboRequestsController < ApplicationController

  # a path that can be hit to load the most recent conversation for a given type
  def conversation
  end

  private

  helper_method :robo_request
  def robo_request
    @robo_request ||= RoboRequest.find(params[:id])
  end
end
