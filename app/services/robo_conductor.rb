class RoboConductor
  attr_reader :parent, :request_type

  def initialize(parent, request_type)
    # RoboJob or GitCommit or Action
    @parent = parent
    @request_type = request_type
  end

  def run_request
    if request_type == "build_plan...TODO"
      # queue up different robots to run against each other

    else
      # Run a single robo request
      runner = get_runner_klass.new(parent, request_type)
      runner.gooo

    end
  end

  private

  def get_runner_klass
    case request_type
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
    else
      raise "Unknown request type: #{request_type}"
    end
  end

end
