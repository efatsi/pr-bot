class AddGeneratedPlanToRoboJobs < ActiveRecord::Migration[7.0]
  def change
    add_column :robo_jobs, :generated_plan, :json
  end
end
