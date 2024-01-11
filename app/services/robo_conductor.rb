class RoboConductor
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

      runner_klass.new(robo_request)
    end
  end
end
