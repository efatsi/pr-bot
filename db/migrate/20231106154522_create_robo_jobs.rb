class CreateRoboJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :robo_jobs do |t|
      t.string :filepath, null: false
      t.text :project_context
      t.text :feature_request, null: false
      t.string :relevant_files, array: true, default: []
      t.text :generated_instructions

      t.timestamps
    end
  end
end
