class RemoveRoboChangesAndActionTemplates < ActiveRecord::Migration[7.0]
  def up
    remove_foreign_key :actions, :action_templates

    drop_table :robo_changes
    drop_table :action_templates
  end

  def down
    create_table :robo_changes do |t|
      t.belongs_to :robo_job, null: false, foreign_key: true
      t.json :raw_json, null: false
      t.text :summary
      t.string :file, null: false
      t.string :action, null: false
      t.text :original_content
      t.text :new_content, null: false
      t.string :status, default: "pending", null: false
      t.string :error
      t.string :new_file

      t.timestamps
    end

    create_table :action_templates do |t|
      t.string :name, null: false
      t.string :description
      t.boolean :system_action, default: false
      t.string :command
      t.string :reverse_command
      t.json :arguments_schema, default: []

      t.timestamps
    end

    add_foreign_key :actions, :action_templates
  end
end
