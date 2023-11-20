class AddStatusToGitCommit < ActiveRecord::Migration[7.0]
  def change
    add_column :git_commits, :status, :string, default: "pending"
    add_column :git_commits, :error, :string
  end
end
