class CreateContextualFiles < ActiveRecord::Migration[7.0]
  def change
    create_table :contextual_files do |t|
      t.belongs_to :robo_job, null: false, foreign_key: true
      t.string :filepath
      t.string :status
      t.json :robo_analysis

      t.timestamps
    end
  end
end
