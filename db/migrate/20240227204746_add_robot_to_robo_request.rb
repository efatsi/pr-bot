class AddRobotToRoboRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :robo_requests, :robot, :string
  end
end
