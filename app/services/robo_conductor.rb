class RoboConductor
  attr_reader :parent, :request_type

  def initialize(parent, request_type)
    # RoboJob or GitCommit or Action
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
        JobRunners::ContextualFiles::Runner
      when "build_plan"
        JobRunners::BuildPlan::Runner
      when "instructions"
        JobRunners::Instructions::Runner
      when "followup_instructions"
        JobRunners::FollowupInstructions::Runner
      when "commit_suggestions"
        JobRunners::CommitSuggestions::Runner
      when *Action.action_types
        ActionRunners::BaseActionRunner
      end

      runner_klass.new(robo_request)
    end
  end
end
