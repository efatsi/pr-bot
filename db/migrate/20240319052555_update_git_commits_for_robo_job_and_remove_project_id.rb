class UpdateGitCommitsForRoboJobAndRemoveProjectId < ActiveRecord::Migration[7.0]
  def change
    GitCommit.delete_all
    change_column_null :git_commits, :robo_job_id, false
    remove_reference :git_commits, :project, index: true, foreign_key: true
  end
end
