module Runners
  class BasePromptGenerator
    attr_reader :robo_request

    def initialize(robo_request)
      @robo_request = robo_request
    end

    private

    def project
      @project ||= robo_request.project
    end
  end
end
