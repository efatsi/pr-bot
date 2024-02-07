module Robots
  class BaseRobot
    def initialize(external_stream_proc=print_proc)
      @external_stream_proc = external_stream_proc
    end

    def handle_streamed_content(new_content)
      if new_content
        @response += new_content
        @external_stream_proc.call(new_content)
      end
    end

    # have this here as a default for testing
    def print_proc
      proc { |msg| print msg }
    end
  end
end
