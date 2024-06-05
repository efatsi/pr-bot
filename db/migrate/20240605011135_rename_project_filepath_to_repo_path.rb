class RenameProjectFilepathToRepoPath < ActiveRecord::Migration[7.0]
  def change
    rename_column :projects, :filepath, :repo_path
  end
end
