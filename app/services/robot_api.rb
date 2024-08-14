class RobotApi
  def initialize(external_stream_proc = print_proc)
    @external_stream_proc = external_stream_proc
  end

  def conversation(prompt_messages, model: "gpt-4")
    robot = get_robot(model)
    robot.conversation(prompt_messages)
  end

  def chat(message, model: "gpt-4")
    robot = get_robot(model)
    robot.chat(message)
  end

  def code_chat(message, model: "gpt-4")
    prompt_messages = [
      { role: "user", content: PromptHub::SYSTEM_SETUP },
      { role: "system", content: PromptHub::ROGER_THAT },
      { role: "user", content: message }
    ]

    robot = get_robot(model)
    robot.conversation(prompt_messages)
  end

  private

  def get_robot(model)
    # eg: "gpt-4-mini" => "Gpt4Mini"
    class_name = model.to_s.split('-').map(&:capitalize).join
    klass = "Robots::#{class_name}".constantize

    klass.new(@external_stream_proc)
  rescue NameError
    available_robots = Robots::BaseRobot.descendants.map(&:name)
    robot_keys = available_robots.map do |robot|
      # replace word/number boundaries with dashes
      robot.split('::').last.gsub(/(?<!^)([A-Z0-9])/, '-\1').downcase
    end

    raise "Invalid model key: #{model}. Must be one of [#{robot_keys.join(', ')}]"
  end

  # have this here as a default for testing
  def print_proc
    proc { |msg| print msg }
  end
end
