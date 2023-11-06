class CreateRoboRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :robo_requests do |t|
      t.belongs_to :robo_job, null: false, foreign_key: true
      t.string :request_type, null: false
      t.text :prompt, null: false
      t.text :response
      t.json :raw_response, null: false, default: {}

      t.timestamps
    end
  end
end
