class AddStatusToRoboRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :robo_requests, :status, :string, default: "active"
  end
end
