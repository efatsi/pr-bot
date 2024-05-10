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
    klass = if model.to_s == "gpt-4"
      Robots::Gpt4
    if model.to_s == "gpt-4-vision"
      Robots::Gpt4Vision
    elsif model.to_s == "gpt-3"
      Robots::Gpt3
    elsif model.to_s == "gemini"
      Robots::Gemini
    else
      raise "Invalid model key: #{model}. Must be one of ['gpt-4', 'gpt-3', 'gemini']"
    end

    klass.new(@external_stream_proc)
  end

  # have this here as a default for testing
  def print_proc
    proc { |msg| print msg }
  end
end
