class RoboConductor
  include ServiceStreamHelpers

  # Toggle this off to disable fetches to the AI API
  ROBOT_ENABLED = true

  attr_reader :parent, :request_type=

  def initialize(parent, request_type)
    # RoboJob or GitCommit
    @parent = parent
    @request_type = request_type
  end

  def run_request
    robo_request = parent.robo_requests.new(request_type: request_type)
    runner = get_runner(robo_request)
    runner.gooo
  end

  private

  def robot_api
    @robot_api ||= RobotApi.new
  end

  def get_runner(robo_request)
    @runner ||= begin
      runner_klass = case request_type
      when "contextual_files"
        Runners::ContextualFilesRunner
      when "build_plan"
        Runners::BuildPlanRunner
      when "instructions"
        Runners::InstructionsRunner
      when "followup_instructions"
        Runners::FollowupInstructionsRunner
      when "commit_suggestions"
        Runners::CommitSuggestionsRunner
      end

      runner_klass.new(robo_request, stream_proc)
    end
  end

  def stream_proc
    proc do |new_chars|
      ActionCable.server.broadcast(parent.stream_key, {
        turbo_stream: turbo_stream.append(
          "ai-response",
          plain: new_chars
        )
      })
    end
  end
end
