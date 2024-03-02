class RoboRequestsController < ApplicationController

  # a path that can be hit to load the most recent conversation for a given type
  def conversation
  end

  def accept
    robo_request.sibling_requests.update_all(status: "ignored")

    render turbo_stream: [
      turbo_stream.update(
        "robo-event-details-#{ robo_request.robo_event.id }",
        partial: "robo_events/enhance_feature_request/details",
        locals: { robo_event: robo_request.robo_event, open_on_load: true }
      ),
    ]
  end

  def ignore
    robo_request.update(status: "ignored")

    render turbo_stream: [
      turbo_stream.update(
        "robo-event-details-#{ robo_request.robo_event.id }",
        partial: "robo_events/enhance_feature_request/details",
        locals: { robo_event: robo_request.robo_event, open_on_load: true }
      ),
    ]
  end

  private

  helper_method :robo_request
  def robo_request
    @robo_request ||= RoboRequest.find(params[:id])
  end
end
