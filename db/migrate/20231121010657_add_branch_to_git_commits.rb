class AddBranchToGitCommits < ActiveRecord::Migration[7.0]
  def change
    add_column :git_commits, :branch, :string
  end
end
