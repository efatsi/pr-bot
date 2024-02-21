class CreateRoboEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :robo_events do |t|
      t.references :parent_robo_event, foreign_key: { to_table: :robo_events }, index: true
      t.references :subject, polymorphic: true, null: false
      t.string :event_type, null: false
      t.string :status, null: false, default: "active"
      t.json :event_data, default: {}

      t.timestamps
    end
  end
end
