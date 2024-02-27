module Robots
  class Gpt3 < Gpt4
    GPT_3_TURBO = "gpt-3.5-turbo-0125"

    private

    def model_key
      GPT_3_TURBO
    end
  end
end
