class MakeGeneratedInstructionsJson < ActiveRecord::Migration[7.0]
  def up
    RoboJob.all.each do |robo_job|
      if robo_job.generated_instructions? && !robo_job.generated_instructions.is_a?(Hash)
        robo_job.update!(generated_instructions: JSON.parse(robo_job.generated_instructions))
      end
    end
  end

  def down
    # noop
  end
end
