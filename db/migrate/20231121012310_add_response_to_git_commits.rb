class AddResponseToGitCommits < ActiveRecord::Migration[7.0]
  def change
    add_column :git_commits, :response, :text
  end
end
