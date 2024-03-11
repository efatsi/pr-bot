class RemoveGeneratedInstructionsFromRoboJobs < ActiveRecord::Migration[7.0]
  def change
    remove_column :robo_jobs, :generated_instructions, :json
  end
end
