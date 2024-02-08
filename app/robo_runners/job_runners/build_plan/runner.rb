module JobRunners::BuildPlan
  class Runner < JobRunners::Instructions::Runner

    # similar in every way to the instructions runner except handling response & label

    private

    def primary_label
      "Build Plan"
    end

  end
end
