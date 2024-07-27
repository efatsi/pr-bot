module JobRunners::ExamineContextualFiles
  class Prompt < BasePromptGenerator

    alias :contextual_file :subject
    delegate :robo_job, to: :contextual_file

    def prompt_messages
      [
        { role: "user", content: file_examiner_setup },
        { role: "system", content: PromptHub::ROGER_THAT },
        { role: "user", content: examine_file_prompt },
      ]
    end

    private

    def file_examiner_setup
      [
        PromptHub::SYSTEM_SETUP,
        "Your task is to help narrow down the list of files that are relevant to the feature request.",
        "First you will review the feature request.",
        "Then you will examine a single file and return its relevance to the and possible solution."
      ].join("\n")
    end

    def feature_and_files_prompt
      [
        "The feature request you will examine files for:",
        "<feature_request>",
        robo_job.enhanced_feature_request,
        "</feature_request>",
        "",
        robo_job_context_files,
      ].join("\n")
    end

    def examine_file_prompt
      [
        "Examine the following file, which came with the reasoning:",
        "#{contextual_file.robo_reasoning}",
        "<file:#{contextual_file.filepath}>",
        contextual_file.file_content,
        "</file:#{contextual_file.filepath}>",
        "",
        "Return the relevance of the provided file #{PromptHub::RETURN_AS_JSON}",
        "- relevance: on a scale of 1-5, how important the file's is to the feature implementation",
        "- explanation: a brief explanation for your ranking. Keep this between 20 words if it's easy to explain, or 50 words if there are a few relevant concepts worth mentioning.",
      ].join("\n")
    end

  end
end
