class CreateRoboChanges < ActiveRecord::Migration[7.0]
  def change
    create_table :robo_changes do |t|
      t.belongs_to :robo_job, null: false, foreign_key: true
      t.json :raw_json, null: false
      t.text :summary
      t.string :file
      t.string :action
      t.text :original_content
      t.text :new_content

      t.timestamps
    end
  end
end
