class AddNewFileToRoboChange < ActiveRecord::Migration[7.0]
  def change
    add_column :robo_changes, :new_file, :string
    change_column_null :robo_changes, :new_content, true
  end
end
