class RemoveMessageOptionsFromGitCommits < ActiveRecord::Migration[7.0]
  def change
    remove_column :git_commits, :message_options, :json
  end
end
