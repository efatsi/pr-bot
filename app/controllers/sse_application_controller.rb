class SseApplicationController < ApplicationController
  include ActionController::Live

  private

  def sse_proc
    return proc do |new_chars|
      sse.write({
        turbo_stream: turbo_stream.append(
          "ai-response",
          plain: new_chars
        )
      })
    end
  end

  def set_sse_headers
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Last-Modified'] = Time.now.httpdate
  end

  attr_reader :sse
  def sse
    @sse ||= SSE.new(response.stream, event: "message")
  end
end
