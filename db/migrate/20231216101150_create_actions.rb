class CreateActions < ActiveRecord::Migration[7.0]
  def change
    create_table :actions do |t|
      t.belongs_to :robo_job, null: false, foreign_key: true
      t.belongs_to :action_template, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.json :arguments, default: []
      t.json :history, default: []

      t.timestamps
    end
  end
end
