class RoboConductor
  attr_reader :robo_event

  def initialize(robo_event)
    @robo_event = robo_event
  end

  def start_request
    runner = get_runner_klass.new(robo_event)
    runner.gooo
  end

  def run_request(robo_request)
    runner = get_runner_klass.new(robo_event)
    runner.run_request(robo_request)
  end

  def finish_request
    runner = get_runner_klass.new(robo_event)
    runner.stoooop
  end

  private

  def get_runner_klass
    case robo_event.event_type
    when "enhance_feature_request"
      JobRunners::EnhanceFeatureRequest::Runner
    when "build_instructions"
      JobRunners::Instructions::Runner
    when "followup_instructions"
      JobRunners::FollowupInstructions::Runner
    when "commit_suggestions"
      JobRunners::CommitSuggestions::Runner
    else
      raise "Unknown request type: #{robo_event.event_type}"
    end
  end

end
