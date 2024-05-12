class RenameContextualFiles < ActiveRecord::Migration[7.0]
  def change
    rename_column :robo_jobs, :contextual_files, :seed_contextual_files
  end
end
