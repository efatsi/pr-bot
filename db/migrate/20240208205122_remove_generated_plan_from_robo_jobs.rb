class RemoveGeneratedPlanFromRoboJobs < ActiveRecord::Migration[7.0]
  def change
    remove_column :robo_jobs, :generated_plan, :json
  end
end
