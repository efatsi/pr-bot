class RoboConductor
  attr_reader :robo_event

  def initialize(robo_event)
    @robo_event = robo_event
  end

  def run_request
    if robo_event.event_type == "enhance_contextual_files"
      # for this event type, run two runners in sequence
      expand_runner = JobRunners::ExpandContextualFiles::Runner.new(robo_event, "expand_contextual_files")
      expand_runner.gooo

      collapse_runner = JobRunners::CollapseContextualFiles::Runner.new(robo_event, "collapse_contextual_files")
      collapse_runner.gooo

    else
      # for the rest, run a single runner
      runner = get_runner_klass.new(robo_event, robo_event.event_type)
      runner.gooo

    end
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
