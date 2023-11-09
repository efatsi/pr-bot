class CreateProjectsAndUpdateRoboJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.string :filepath, null: false
      t.text :project_context, null: false

      t.timestamps
    end

    add_reference :robo_jobs, :project, foreign_key: true

    RoboJob.find_each do |robo_job|
      project = Project.find_or_create_by!(filepath: robo_job.filepath, project_context: robo_job.project_context)
      robo_job.update!(project: project)
    end

    remove_column :robo_jobs, :filepath
    remove_column :robo_jobs, :project_context
  end
end
