class AddRobotsToRoboEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :robo_events, :robots, :string, array: true, default: []
  end
end
