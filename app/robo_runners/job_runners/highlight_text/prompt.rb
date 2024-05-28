module JobRunners::HighlightText
  class Prompt < BasePromptGenerator

    alias :contextual_file :subject
    delegate :robo_job, to: :contextual_file

    def prompt_messages
      [
        { role: "user", content: highlight_text_setup },
        { role: "system", content: example_response },
        { role: "user", content: highlight_text_prompt },
      ]
    end

    private

    def highlight_text_setup
      [
        "Highlight the key words in this message",
        "Return in markdown format",
        "Use **bold** and _italics_ notation to highlight key words",
        "",
        "Return the formatted text #{PromptHub::RETURN_AS_JSON}",
        "- formatted_text: the same text as input but with highlights.",
        "",
        "Now, highlight this text:",
        "This file defines the Customer model with all the necessary fields required for the CustomerDetailView feature. It is crucial for sourcing and displaying customer data."
      ].join("\n")
    end

    def example_response
      JSON.pretty_generate({
        formatted_text: "This file defines the **Customer** model with all the necessary fields _required_ for the **CustomerDetailView** feature. It is crucial for **sourcing** and **displaying customer data**."
      })
    end

    def highlight_text_prompt
      [
        "Now, highlight this text:",
        contextual_file.robo_reasoning
      ].join("\n")
    end
  end
end
