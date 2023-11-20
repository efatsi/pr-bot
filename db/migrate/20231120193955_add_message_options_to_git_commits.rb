class AddMessageOptionsToGitCommits < ActiveRecord::Migration[7.0]
  def change
    add_column :git_commits, :message_options, :json, default: {}
  end
end
