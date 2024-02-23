class AddRoboEventToRoboRequests < ActiveRecord::Migration[7.0]
  def change
    add_reference :robo_requests, :robo_event, null: true, foreign_key: true
  end
end
