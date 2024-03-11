class AddErrorToRoboRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :robo_requests, :error, :text
  end
end
