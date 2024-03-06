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

  def edit_enhanced_feature_request
  end

  def update_enhanced_feature_request
    feature_params = params.require(:robo_request).permit(:response)
    robo_request.update(feature_params)

    render(
      partial: "robo_events/enhance_feature_request/details",
      locals: { robo_event: robo_request.robo_event, open_on_load: true }
    )
  end

  private

  helper_method :robo_request
  def robo_request
    @robo_request ||= if params[:id]
      RoboRequest.find(params[:id])
    elsif params[:robo_request_id]
      RoboRequest.find(params[:robo_request_id])
    end
  end
end
