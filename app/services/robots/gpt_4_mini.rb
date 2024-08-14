module Robots
  class Gpt4Mini < Gpt4
    GPT_4_MINI = "gpt-4o-mini"

    private

    def model_key
      GPT_4_MINI
    end
  end
end
