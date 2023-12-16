class CreateActionTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :action_templates do |t|
      t.belongs_to :project, foreign_key: true
      t.string :name, null: false
      t.string :description
      t.boolean :system_action, default: false
      t.string :command
      t.string :reverse_command
      t.json :arguments_schema, default: []

      t.timestamps
    end
  end
end
