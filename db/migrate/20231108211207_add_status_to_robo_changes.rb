class AddStatusToRoboChanges < ActiveRecord::Migration[7.0]
  def change
    add_column :robo_changes, :status, :string, default: "pending", null: false
    add_column :robo_changes, :error, :string
  end
end
