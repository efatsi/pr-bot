class SseApplicationController < ApplicationController
  include ActionController::Live

  private

  def set_sse_headers
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Last-Modified'] = Time.now.httpdate
  end

  attr_reader :sse
  def sse
    @sse ||= SSE.new(response.stream, event: "message")
  end
end
