class RenameFilesInRoboJobs < ActiveRecord::Migration[7.0]
  def change
    rename_column :robo_jobs, :relevant_files, :contextual_files
  end
end
