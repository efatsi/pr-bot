class CreateGitCommits < ActiveRecord::Migration[7.0]
  def change
    create_table :git_commits do |t|
      t.string :commit_hash
      t.text :message
      t.references :project, null: false, foreign_key: true
      t.references :robo_job, null: true, foreign_key: true

      t.timestamps
    end
    add_index :git_commits, :commit_hash, unique: true
  end
end
