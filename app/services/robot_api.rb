class RobotError < StandardError; end

class RobotApi
  def ask(prompt_messages, external_stream_proc: print_proc, model: :gpt)
    robot = if model == :gpt
      Robots::Gpt.new(external_stream_proc)
    elsif model == :gemini
      Robots::Gemini.new(external_stream_proc)
    end

    robot.ask(prompt_messages)
  end

  def chat(message, external_stream_proc: print_proc, model: :gpt)
    robot = if model == :gpt
      Robots::Gpt.new(external_stream_proc)
    elsif model == :gemini
      Robots::Gemini.new(external_stream_proc)
    end

    robot.chat(message)
  end

  def chat_google(message)
    google_prompts = [
      { role: 'model', parts: { text: "I'm am a helpful assistant" } },
      { role: 'user', parts: { text: message } }
    ],

    { contents: { role: 'user', parts: { text: message } } }

    @response = ""
    result = client.stream_generate_content(google_prompts) do |event, parsed, raw|
      new_content = event.dig("candidates", 0, "content", "parts", 0, "text")
      @response += new_content

      print(new_content)
    end

    puts
    @response
  end

  private

  # have this here as a default for testing
  def print_proc
    proc { |msg| print msg }
  end

end
