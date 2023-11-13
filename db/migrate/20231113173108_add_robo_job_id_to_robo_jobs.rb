class AddRoboJobIdToRoboJobs < ActiveRecord::Migration[7.0]
  def change
    add_reference :robo_jobs, :parent_job, null: true, foreign_key: { to_table: :robo_jobs }
  end
end
